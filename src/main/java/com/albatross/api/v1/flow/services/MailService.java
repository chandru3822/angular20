package com.albatross.api.v1.flow.services;

import com.albatross.api.config.PropertiesConfiguration;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SMTPAuthenticator;
import com.albatross.api.utils.SqlCache;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

@Service
@Slf4j
public class MailService {

    private final PropertiesConfiguration propConfig;

    @Autowired
    public MailService(PropertiesConfiguration propConfig) {
        this.propConfig = propConfig;
    }

    @Autowired
    SecurityService securityService;

    @Autowired
    SqlCache sqlCache;

    public void sendMessage(String to, String subject, String message, String sentByEmail, String sentByName, Long sentByUserId) {
        sendMessage(to, subject, message, null, sentByEmail, sentByName, sentByUserId);
    }

    public void sendMessage(String to, String subject, String message, Map<String, DataSource> attachments, String sentByEmail, String sentByName, Long sentByUserId) {
        // log.info("Sending message to {}: {}\n{}\n\n", to, subject, message);

        // NOTE: if email is for amy or jessica then you should send in SalesOps@blueravensolar.com as the email address
        HashMap<String, Object> params = new HashMap<>();

        if(null == sentByEmail){
            sentByEmail = "support@blueravensolar.com";
        }

        Properties props = new Properties();
        props.put("mail.transport.protocol", "smtp");
        props.put("mail.smtp.host", propConfig.getSmtpServer());
        props.put("mail.smtp.port", propConfig.getSmtpPort());
        Session session;
        if (!StringUtils.isEmpty(propConfig.getSmtpUser()) && !StringUtils.isEmpty(propConfig.getSmtpPassword())) {
            props.put("mail.smtp.user", propConfig.getSmtpUser());
            props.put("mail.smtp.auth", "true");
            session = Session.getInstance(props, new SMTPAuthenticator(propConfig.getSmtpUser(),
                    propConfig.getSmtpPassword()));
        } else {
            session = Session.getDefaultInstance(props, null);
        }

        try {

            // TODO: 4/10/17 move to props file
            Message msg = new MimeMessage(session);
            InternetAddress salesOperationsEmail = new InternetAddress(sentByEmail, sentByName);

            msg.setFrom(salesOperationsEmail);
            msg.setReplyTo(new Address[]{salesOperationsEmail});
            msg.addRecipient(Message.RecipientType.TO, new InternetAddress(StringUtils.trimWhitespace(to)));

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

            log.info("EMAIL: MESSAGE SENT");

            params.put("from", sentByEmail);
            params.put("to", to);
            params.put("subject", subject);
            params.put("message", message);
            params.put("attachments", attachmentNames.isEmpty() ? null : attachmentNames.toString().replace("[", "").replace("]", ""));
            params.put("userId", sentByUserId);
            sqlCache.update("email.insert", params);
        } catch (Exception e) {
            log.error("EMAIL: SEND_MAIL_EXCEPTION", e);
        }
    }
}
