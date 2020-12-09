package com.albatross.api.v1.flow.services;

import com.albatross.api.v1.flow.enums.RecipientType;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.EmailMessage;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Service;

import javax.mail.internet.InternetAddress;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URL;
import java.util.*;
import java.util.concurrent.Future;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CommunicationService {

  private final TemplatingEngineService templatingEngineService;
  private final UserService userService;
  private final MailService mailService;
  private final SMSService smsService;

  @Async
  public Future<Void> sendEmails(String subject, List<Long> userIDs, String templateContent, Map<String, javax.activation.DataSource> attachments, URL emailUnsubscribeURL, String sentByEmail) {
    for (Long userID : userIDs) {
      Optional<User> user = userService.getUser(userID, false);
      //do not send email if they do not have access to the system
      if (user.isPresent() && user.get().getUserStatusType() != null && user.get().getHasAccess()) {
        sendEmail(subject, user.get().getEmail(), user.get(), templateContent, attachments, emailUnsubscribeURL, sentByEmail);
      }
    }
    return new AsyncResult<>(null);
  }

  @Async
  public void sendEmail(EmailMessage msg) {
    sendEmail(msg.getSubject(),
            msg.getRecipientEmailAddr(),
            msg.getRecipientUser(),
            msg.getTemplate(),
            msg.getAttachments(),
            msg.getUnsubscribeUrl(),
            msg.getSenderEmailAddr());
  }

  @Async
  public Future<Void> sendEmail(String subject, String emailAddress, User user, String templateContent, Map<String, javax.activation.DataSource> attachments, URL emailUnsubscribeURL, String sentByEmail) {
    //don't send email if user does not have access to the system
    if (user != null && user.getUserStatusType() != null && user.getHasAccess()){

      try (ByteArrayOutputStream output = new ByteArrayOutputStream()) {
        Map<String, Object> contextMap = new HashMap<>();
        contextMap.put("unsubscribeURL", emailUnsubscribeURL + "?emailAddress=" + emailAddress);
        contextMap.put("user", user);

        renderTemplate(templateContent, output, contextMap);
        mailService.sendMessage(emailAddress, subject, output.toString(), attachments, sentByEmail);

      } catch (Exception ex) {
        log.error("EMAIL: ERROR: Error sending email to address={}", emailAddress, ex);
      }
    }
    return new AsyncResult<>(null);
  }

  @Async
  public void sendEmail(String subject, String email, String template, Map<String, Object> context, String sentByEmail) {
    try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
      renderTemplate(template, baos, context);
      // log.info("RENDERED EMAIL: to:{} subject:{}\n{}", email, subject, baos.toString());
      mailService.sendMessage(email, subject, baos.toString(), null, sentByEmail);
    } catch (Exception e) {
      log.error("EMAIL: ERROR: Error sending email to address={}", email, e);
      e.printStackTrace();
    }
  }

  public void sendEmail(String subject, List<String> emails, String template, Map<String, Object> context, InternetAddress sentByEmail, List<String> cc) throws Exception {
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      renderTemplate(template, baos, context);
      // log.info("RENDERED EMAIL: to:{} subject:{}\n{}", email, subject, baos.toString());
      mailService.sendMessage(emails, subject, baos.toString(), null, sentByEmail, cc);
  }

  @Async
  public void queueTextMessages(String messageGroupId, Optional<User> userIn, String templateContent, List<URI> mediaURLs) {
      //dont try to send text if there is no phone number or the user doesnt have access
      if (userIn.isPresent() && userIn.get().getPhoneNumber() != null && userIn.get().getUserStatusType() != null && userIn.get().getHasAccess()) {
        User user = userIn.get();
        try (ByteArrayOutputStream output = new ByteArrayOutputStream()) {
          Map<String, Object> contextMap = new HashMap<>();
          contextMap.put("user", user);
          renderTemplate(templateContent, output, contextMap);

          smsService.queueMessage(messageGroupId, user.getId(), user.getPhoneNumber(), output.toString(), mediaURLs, RecipientType.USER);
        } catch (Exception ex) {
          log.error("MESSAGING: Error queueing SMS ", ex);
        }
      }
  }

  @Async
  public void queueTextMessagesForProject(String messageGroupId, Contact contact, String toPhone, String templateContent, List<URI> mediaURLs) {
      try (ByteArrayOutputStream output = new ByteArrayOutputStream()) {
          Map<String, Object> contextMap = new HashMap<>();
          contextMap.put("contact", contact);
          renderTemplate(templateContent, output, contextMap);

          smsService.queueMessage(messageGroupId, contact.getId(), toPhone, output.toString(), mediaURLs, RecipientType.PROJECT);
      } catch (Exception ex) {
          log.error("MESSAGING: Error queueing SMS ", ex);
      }
  }

  public void renderTemplate(String templateContent, OutputStream output, Map<String, Object> contextMap) throws Exception {
    templatingEngineService.applyFreemarkerTemplate(templateContent, contextMap, output);
  }

  public String getDefaultEmailTemplate() throws IOException {
    try (InputStream input = CommunicationService.class.getResourceAsStream("/communication/templates/email.ftl.txt")) {
      return new Scanner(input, "UTF-8").useDelimiter("\\A").next();
    }
  }

}
