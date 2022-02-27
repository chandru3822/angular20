package com.albatross.api.v1.flow.services;

import com.albatross.api.config.PropertiesConfiguration;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SMTPAuthenticator;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.EmailSender;
import com.albatross.api.v1.flow.model.User;
import com.google.common.util.concurrent.RateLimiter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import java.util.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
@Service
@RequiredArgsConstructor
public class MailService {

  private final PropertiesConfiguration propConfig;
  private final ThreadPoolTaskExecutor taskExecutor;
  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public void sendMessage(
      String to,
      String subject,
      String message,
      String sentByEmail,
      String sentByName,
      Long sentByUserId) {
    sendMessage(to, subject, message, null, sentByEmail, sentByName, sentByUserId);
  }

  public void sendMessage(
      String to,
      String subject,
      String message,
      Map<String, DataSource> attachments,
      String sentByEmail,
      String sentByName,
      Long sentByUserId) {

    Session session = getSession();

    if (null == sentByEmail) {
    	sentByEmail = getDefaultSenderEmailAddress();
    }

    try {

      Message msg = new MimeMessage(session);
      InternetAddress salesOperationsEmail = new InternetAddress(sentByEmail, sentByName);

      msg.setFrom(salesOperationsEmail);
      msg.setReplyTo(new Address[] {salesOperationsEmail});
      msg.addRecipient(
          Message.RecipientType.TO, new InternetAddress(StringUtils.trimWhitespace(to)));

      msg.setSubject(subject);

      Multipart multiPart = new MimeMultipart();
      MimeBodyPart bodyPart = new MimeBodyPart();
      bodyPart.setContent(message, "text/html; charset=utf-8");
      multiPart.addBodyPart(bodyPart);
      ArrayList<String> attachmentNames = new ArrayList<>();
      if (attachments != null && attachments.size() > 0) {

        for (String attachmentName : attachments.keySet()) {

          DataSource attachment = attachments.get(attachmentName);

          MimeBodyPart attachmentPart = new MimeBodyPart();
          attachmentPart.setDataHandler(new DataHandler(attachment));
          attachmentPart.setFileName(attachmentName);
          multiPart.addBodyPart(attachmentPart);
          attachmentNames.add(attachmentName);
        }
      }
      msg.setContent(multiPart);
      Transport.send(msg);

      insertEmail(sentByEmail, to, subject, message, attachmentNames, sentByUserId, true, sentByName);
      log.debug("EMAIL: MESSAGE SENT");
    } catch (Exception e) {
      log.error("EMAIL: SEND_MAIL_EXCEPTION", e);
    }
  }

  /**
   * Called from the CRON. Will try to send all "unprocessed" emails that are inserted directly
   * into the db by functions and other ways not handled by the backend
   */
  public void sendUnprocessedEmails() throws InterruptedException {
    //get all unprocessed emails
    List<EmailMessage> unprocessedEmails = sqlCache.query("email.getAllUnprocessed", Collections.emptyMap(), EmailMessage.class);

    //TODO: it would be cool if this could send "templated" emails, and pass in an array of params so we could make .ftl files for these and format them more easily

    //currently this fn is not able to send attachments.
    // would need to refactor a bit in order to handle that
    sendBulkMessages(unprocessedEmails, null, true);
  }

  /**
   * Attempting to process emails at a faster pace
   * - Reuse the same session
   * - Spin up some threads
   * - Fire
   * @param messages
   * @param attachments
   * @throws InterruptedException
   * @return
   */
  public int sendBulkMessages(List<EmailMessage> messages, Map<String, DataSource> attachments, Boolean sendingUnprocessedEmails)
      throws InterruptedException {

    Session session = getSession();

    final AtomicInteger counter = new AtomicInteger(0);
    final RateLimiter rateLimiter = RateLimiter.create(propConfig.getSmtpRateLimit());
    final CountDownLatch latch = new CountDownLatch(messages.size());

    for (EmailMessage message : messages) {
      rateLimiter.acquire();

      taskExecutor.submit(
          () -> {
            try (final Transport transport = session.getTransport("smtp")) {
              transport.connect();

              final MimeMessage mimeMessage = new MimeMessage(session);

              String from = message.getFrom();
              if (null == from) {
                from = getDefaultSenderEmailAddress();
              }

              final InternetAddress fromAddress =
                  new InternetAddress(StringUtils.trimWhitespace(from), message.getFromDisplayName());
              mimeMessage.setFrom(fromAddress);
              mimeMessage.setReplyTo(new Address[] {fromAddress});
              mimeMessage.addRecipient(
                  Message.RecipientType.TO,
                  new InternetAddress(StringUtils.trimWhitespace(message.getTo())));

              mimeMessage.setSubject(message.getSubject());

              MimeBodyPart bodyPart = new MimeBodyPart();
              bodyPart.setContent(message.getContent(), "text/html; charset=utf-8");

              Multipart multiPart = new MimeMultipart();
              multiPart.addBodyPart(bodyPart);
              ArrayList<String> attachmentNames = new ArrayList<>();
              if (attachments != null && attachments.size() > 0) {
                for (String attachmentName : attachments.keySet()) {
                  DataSource attachment = attachments.get(attachmentName);

                  MimeBodyPart attachmentPart = new MimeBodyPart();
                  attachmentPart.setDataHandler(new DataHandler(attachment));
                  attachmentPart.setFileName(attachmentName);
                  multiPart.addBodyPart(attachmentPart);
                  attachmentNames.add(attachmentName);
                }
              }
              mimeMessage.setContent(multiPart);
              mimeMessage.saveChanges();
              log.debug("EMAIL: Sending email to {}", message.getTo());
              transport.sendMessage(mimeMessage, mimeMessage.getAllRecipients());

              if(sendingUnprocessedEmails) {
                markEmailProcessed(message.getId());
              } else {
                insertEmail(
                  from,
                  message.getTo(),
                  message.getSubject(),
                  message.getContent(),
                  attachmentNames,
                  message.getSentByUserId(),
                  true,
                  message.getFromDisplayName());
              }

              // count the number of successful emails sent
              counter.getAndIncrement();

            } catch (Exception e) {
              log.error("EMAIL: {}", e.getMessage());
            } finally {
              latch.countDown();
            }
          });
    }

    // wait for everything to complete
    latch.await();

    // return the number of emails actually sent
    return counter.get();
  }

    public List<EmailSender> getEmailSenders(Long companyId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("companyId", companyId);
        try {
            return sqlCache.query("email.getSendersByCompanyId", params, EmailSender.class);
        }
        catch (Exception e){
            return null;
        }
    }

    public List<EmailSender> saveFromEmailAddress(EmailSender emailAddress, boolean updateDefault) {
      HashMap<String, Object> params = new HashMap<>();
        User user = securityService.getCurrentUser();
        params.put("emailAddress", emailAddress.getEmailAddress());
        params.put("senderName", emailAddress.getSenderName());
        params.put("companyId", emailAddress.getCompanyId());
      params.put("createdById", user.getId());

      Long id = sqlCache.updateReturningId("email.saveFromAddress", params, "id").longValue();
        if (updateDefault){
            params.put("isDefault", emailAddress.getIsDefault());
            params.put("id", id);
            sqlCache.update("email.changeDefaultAddress", params);
        }
        return this.getEmailSenders(emailAddress.getCompanyId());
    }

    public List<EmailSender> updateSenderEmailAddress(EmailSender emailAddress, boolean updateDefault){
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", emailAddress.getId());
        params.put("senderName", emailAddress.getSenderName());
        params.put("emailAddress", emailAddress.getEmailAddress());
        params.put("modifiedBy", emailAddress.getModifiedById());
        params.put("isDefault", emailAddress.getIsDefault());
        params.put("companyId", emailAddress.getCompanyId());
        sqlCache.update("email.updateEmailAddress", params);
        if (updateDefault){
            sqlCache.update("email.changeDefaultAddress", params);
        }
        return this.getEmailSenders(emailAddress.getCompanyId());
        //todo: this function makes three separate database calls; I don't know if that's optimized, so let me know if we need to change this
    }

    public void deleteFromEmailAddress(Long emailAddressId, Long userId) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("id", emailAddressId);
      params.put("modifiedBy", userId);
      sqlCache.update("email.deleteEmailAddress", params);
    }

  private Session getSession() {
    Properties props = new Properties();
    props.put("mail.transport.protocol", "smtp");
    props.put("mail.smtp.host", propConfig.getSmtpServer());
    props.put("mail.smtp.port", propConfig.getSmtpPort());

    Session session;
    if (!ObjectUtils.isEmpty(propConfig.getSmtpUser())
        && !ObjectUtils.isEmpty(propConfig.getSmtpPassword())) {
      props.put("mail.smtp.user", propConfig.getSmtpUser());
      props.put("mail.smtp.auth", "true");
      session =
          Session.getInstance(
              props, new SMTPAuthenticator(propConfig.getSmtpUser(), propConfig.getSmtpPassword()));
    } else {
      session = Session.getDefaultInstance(props, null);
    }
    return session;
  }

  private void markEmailProcessed(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.update("email.markProcessed", params);
  }

  private void insertEmail(
      String from,
      String to,
      String subject,
      String message,
      List<String> attachments,
      Long userId,
      Boolean processed,
      String fromDisplayName) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("from", from);
    params.put("to", to);
    params.put("subject", subject);
    params.put("message", message);
    //set the processed param to false if you are inserting a row to the db to be processed by the cron job
    //otherwise set it to true for any other reason
    params.put("processed", processed);
    params.put("fromDisplayName", fromDisplayName);
    params.put(
        "attachments",
        attachments.isEmpty() ? null : attachments.toString().replace("[", "").replace("]", ""));
    params.put("userId", userId);

    sqlCache.update("email.insert", params);
  }

    private String getDefaultSenderEmailAddress() {
        Long companyId = getCompanyIdFromUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("companyId", companyId);

        String defaultEmail = sqlCache.queryForObject("email.getDefaultSenderByCompanyId", params, String.class);
        if(null == defaultEmail){
            throw new RuntimeException("SentByEmail cannot be null");
        }
        return defaultEmail;

    }

    private Long getCompanyIdFromUser() {
        User user = securityService.getCurrentUser();
        return null == user ? 3 : user.getCompanyId(); //todo: sitewide admin doesn't necessarily have user for current company, so we need to figure out how to get the right id
    }
}
