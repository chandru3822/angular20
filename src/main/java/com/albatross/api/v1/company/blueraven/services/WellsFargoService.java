package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.config.WellsFargoConfiguration;
import com.albatross.api.v1.company.blueraven.models.RebatePaymentDetail;
import com.albatross.api.v1.company.blueraven.models.wellsfargo.*;
import com.albatross.api.utils.SqlCache;
import com.jcraft.jsch.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.util.HashMap;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class WellsFargoService {
    private static final String prefix = "WELLSFARGO";

    @Autowired
    private WellsFargoConfiguration config;

    @Autowired
    private SqlCache sqlCache;

    @Autowired
    private JedisPool jedisPool;

    public List<RebatePaymentDetail> getUpcomingRebatePayments() {
      return sqlCache.query("wellsfargo.getUpcomingRebatePayments", null, RebatePaymentDetail.class);
    }

    public void processUpcomingPayments(FlatFile output) throws Exception {
      List<RebatePaymentDetail> payments = getUpcomingRebatePayments();
      if (null != payments && payments.size() > 0) {
        for (RebatePaymentDetail deets : payments) {
          processUpcomingPayment(output, deets);
        }
      } else {
        throw new Exception("Did not find any approved payments");
      }
    }

    public void processUpcomingPayment(FlatFile output, RebatePaymentDetail deets) {
      String memo = String.format("Rebate payment #%d of %d",
        deets.getPaymentNumber(), deets.getTotalPayments());

      PaymentRecord pr = new PaymentRecord(
        getTransactionNumber().toString(),
        deets.getPaymentAmount(),
        config.getAccountNumber(),
        config.getRoutingNumber(),
        memo);

      Integer checkNumber = getCheckNumber();
      SupplementalCheckRecord check = new SupplementalCheckRecord();
      check.setCheckNumber(checkNumber);
      check.setDocumentTemplateNumber(config.getCheckTemplateId());

      output.addCheck(
            pr,
            getSender(),
            getBank(),
            getRecipient(deets),
            check
      );

      //need to save the check number to the payment so we have a record of it and can export it
      HashMap<String, Object> params = new HashMap<>();
      params.put("checkNumber", checkNumber);
      params.put("paymentId", deets.getPaymentId());
      sqlCache.update("wellsfargo.saveCheckNumberToPayment", params);
    }

    public String renderFile() throws Exception {
      //the enabled check is so that we can still test approving in uat
      if (config.getEnabled()) {
        return uploadFlatFile();
      } else {
        return "";
      }
    }

    public Party getSender() {
      Party party = new Party();
      party.setAddressIndicator(AddressIndicator.ORIGINATING_PARTY);
      party.setName(config.getAddressName());
      // party.setIdentificationNumber("123456789~50");
      party.setAddress1(config.getStreet1());
      party.setAddress2(config.getStreet2());
      party.setCity(config.getCity());
      party.setState(config.getState());
      party.setPostalCode(config.getPostalCode());

      return party;
    }

    public Party getBank() {
      Party party = new Party();
      party.setAddressIndicator(AddressIndicator.ORIGINATING_BANK);
      party.setName(config.getBankAddressName());
      party.setAddress1(config.getBankStreet1());
      party.setCity(config.getBankCity());
      party.setState(config.getBankState());
      party.setPostalCode(config.getBankPostalCode());

      return party;
    }

    public Party getRecipient(RebatePaymentDetail deets) {
      Party party = new Party();
      party.setAddressIndicator(AddressIndicator.RECEIVING_PARTY);
      party.setName(deets.getFullName());

      String mailingStreet1 = deets.getMailingStreet1();
      String mailingStreet2 = deets.getMailingStreet2();
      String mailingCity = deets.getMailingCity();
      String mailingState = deets.getMailingState();
      String mailingPostalCode = deets.getMailingPostalCode();

      //if we have a complete mailing address saved use that, otherwise use the customer's address
      if (StringUtils.isNotEmpty(mailingStreet1) && StringUtils.isNotEmpty(mailingCity)
          && StringUtils.isNotEmpty(mailingState) && StringUtils.isNotEmpty(mailingPostalCode)) {

        party.setAddress1(mailingStreet1);

        if (StringUtils.isNotEmpty(mailingStreet2)) {
          party.setAddress2(mailingStreet2);
        }

        party.setCity(mailingCity);
        party.setState(mailingState);
        party.setPostalCode(mailingPostalCode);
      } else {
        party.setAddress1(deets.getStreet1());

        String street2 = deets.getStreet2();
        if (StringUtils.isNotEmpty(street2)) {
          party.setAddress2(street2);
        }

        party.setCity(deets.getCity());
        party.setState(deets.getStateAbbr());
        party.setPostalCode(deets.getPostalCode());
      }

      return party;
    }

    public String uploadFlatFile() throws Exception {
      Session session = null;
      Channel channel = null;
      try {
        //make sure we can connect before we approve payments or process payments
        JSch jsch = new JSch();
        jsch.addIdentity(config.getSftpKeyPath());
        String user = config.getSftpUser();
        String password = config.getSftpPassword();
        String host = config.getSftpHost();
        Integer port = config.getSftpPort();

        if (port == null) {
          session = jsch.getSession(user, host);
        } else {
          session = jsch.getSession(user, host, port);
        }

        if (password != null) {
          info("Password specified and configured of length {}", StringUtils.length(password));
          session.setPassword(password);
        }

        //we have disabled strict checking in prod as we cannot figure out how to add the RSA key for safetrans.wellsfargo.com every time we do a release
        if (!config.getSftpCheckHostKey()) {
          session.setConfig("StrictHostKeyChecking", "no");
        }

        info("Connecting to Wells Fargo {}@{} and port {}", user, host, port);
        session.connect();

        channel = session.openChannel("sftp");
        channel.setOutputStream(System.out);
        channel.connect();

        ChannelSftp c = (ChannelSftp) channel;

        FlatFile ff = new FlatFile("0001");
        //process payments after a successful connection, this takes all approved payments and adds them to the flat file
        processUpcomingPayments(ff);

        ByteArrayInputStream file = new ByteArrayInputStream(ff.toString().getBytes());
        info("Upload Path: {}", getUploadPath(ff));
        c.put(file, getUploadPath(ff));
        c.exit();
        info("Uploaded file to Wells Fargo: {}", ff.getControlNumber());
        return ff.toString();
      } catch (Exception ex) {
        error("Failed to upload file: {}", ex);
        ex.printStackTrace();
        throw ex;
      } finally {
        if (channel != null) {
          channel.disconnect();
        }

        if (session != null) {
          session.disconnect();
        }
      }
    }

    public String getUploadPath(FlatFile ff) {
      return new File(
        config.getSftpUploadPath(),
        ff.getControlNumber()
      ).getPath();
    }

    public Integer getTransactionNumber() {
    return incrGet(config.getTransactionNumberKey());
  }

    public Integer getCheckNumber() {
    return incrGet(config.getCheckNumberKey());
  }

    public String getCheckNumberWithoutIncrement() {
        int num = 0;
        try (Jedis jedis = jedisPool.getResource()) {
            String out = jedis.get(config.getCheckNumberKey());
            if (StringUtils.isNotEmpty(out)) {
                num = Integer.parseInt(out);
            }
        }

        return Integer.toString(num);
    }

    public void setCheckNumber(int checkNumber) {
        try (final Jedis jedis = jedisPool.getResource()) {
            jedis.set(config.getCheckNumberKey(), String.valueOf(checkNumber));
        }
    }

    private Integer incrGet(String key) {
        int num = 0;
        try (Jedis jedis = jedisPool.getResource()) {
            jedis.incr(key);
            String out = jedis.get(key);
            if (StringUtils.isNotEmpty(out)) {
                num = Integer.parseInt(out);
            }
        }

        return num;
    }

    private void info(String msg, Object... args) {
    log.info(String.format("%s: %s", prefix, msg), args);
  }

    private void warn(String msg, Object... args) {
    log.warn(String.format("%s: %s", prefix, msg), args);
  }

    private void error(String msg, Object... args) {
    log.error(String.format("%s: %s", prefix, msg), args);
  }
}
