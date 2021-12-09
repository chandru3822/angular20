package com.albatross.api.v1.flow.services;

import com.albatross.api.v1.flow.enums.RecipientType;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.SendTextsRequest;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.Maps;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Service;

import javax.activation.DataSource;
import javax.activation.FileDataSource;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.Future;

@Slf4j
@Service
@RequiredArgsConstructor
public class CommunicationService {

  private final TemplatingEngineService templatingEngineService;
  private final UserService userService;
  private final MailService mailService;
  private final SMSService smsService;
  private final FirebaseMessaging firebaseMessaging;

  @Async
  public Future<Void> sendEmails(
      String subject,
      List<Long> userIDs,
      String templateContent,
      Map<String, javax.activation.DataSource> attachments,
      URL emailUnsubscribeURL,
      String sentByEmail,
      String sentByName,
      Long sentByUserId) {
    for (Long userID : userIDs) {
      Optional<User> user = userService.getUser(userID, false);
      // do not send email if they do not have access to the system
      if (user.isPresent() && user.get().getUserStatusType() != null && user.get().getHasAccess()) {
        sendEmail(
            subject,
            user.get().getEmail(),
            user.get(),
            templateContent,
            attachments,
            emailUnsubscribeURL,
            sentByEmail,
            sentByName,
            sentByUserId);
      }
    }
    return new AsyncResult<>(null);
  }

  @Async
  public Future<Void> sendEmail(
      String subject,
      String emailAddress,
      User user,
      String templateContent,
      Map<String, javax.activation.DataSource> attachments,
      URL emailUnsubscribeURL,
      String sentByEmail,
      String sentByName,
      Long sentByUserId) {
    // don't send email if user does not have access to the system
    if (user != null && user.getUserStatusType() != null && user.getHasAccess()) {

      try {
        Map<String, Object> contextMap = new HashMap<>();
        contextMap.put("unsubscribeURL", emailUnsubscribeURL + "?emailAddress=" + emailAddress);
        contextMap.put("user", user);

        final String template = renderTemplate(templateContent, contextMap);
        mailService.sendMessage(
            emailAddress, subject, template, attachments, sentByEmail, sentByName, sentByUserId);

      } catch (Exception ex) {
        log.error("EMAIL: ERROR: Error sending email to address={}", emailAddress, ex);
      }
    }
    return new AsyncResult<>(null);
  }

  @Async
  public void sendEmail(
      String subject,
      String email,
      String template,
      Map<String, Object> context,
      String sentByEmail,
      String sentByName,
      Long sentByUserId) {
    try {
      final String renderTemplate = renderTemplate(template, context);
      mailService.sendMessage(
          email, subject, renderTemplate, null, sentByEmail, sentByName, sentByUserId);
    } catch (Exception e) {
      log.error("EMAIL: ERROR: Error sending email to address={}", email, e);
      e.printStackTrace();
    }
  }

  @Async
  public void sendBulkEmail(
      String subject,
      String template,
      Map<String, File> attachments,
      URL emailUnsubscribeURL,
      List<User> users,
      String sentByEmail,
      String sentByName,
      Long sentByUserId)
      throws Exception {

    try {
      final Instant startTime = Instant.now();

      final Map<String, DataSource> emailAttachments =
          Maps.transformValues(attachments, FileDataSource::new);

      // do not send email if they do not have access to the system
      final List<EmailMessage> emailMessages =
          users.stream()
              .filter(user -> user.getUserStatusType() != null)
              .filter(User::getHasAccess)
              .map(
                  user -> {
                    try {
                      final String message =
                          renderTemplate(
                              template,
                              Map.of(
                                  "unsubscribeURL",
                                  String.format(
                                      "%s?emailAddress=%s", emailUnsubscribeURL, user.getEmail()),
                                  "user",
                                  user));
                      return
                          new EmailMessage(user.getEmail(), sentByEmail, sentByName, subject, message, sentByUserId, true, null);
                    } catch (Exception e) {
                      log.error(
                          "EMAIL: ERROR: Generating template. template={}, address={}",
                          template,
                          user.getEmail());
                      return null;
                    }
                  })
              .filter(Objects::nonNull)
              .toList();

      log.info("EMAIL: Starting to send out emails. Expected count={}", emailMessages.size());

      final int sentMessages = mailService.sendBulkMessages(emailMessages, emailAttachments, false);

      final Instant endTime = Instant.now();
      log.info(
          "EMAIL: Elapsed time={}, Total emails={}",
          Duration.between(startTime, endTime),
          sentMessages);
    } finally {
      for (File tempFile : attachments.values()) {
        log.debug("EMAIL: Deleting Temp File {}", tempFile.getAbsolutePath());
        if (tempFile.exists()) tempFile.delete();
      }
    }
  }

  @Async
  public void sendMassText(
      String groupId, SendTextsRequest sendTexts, List<User> users, User loggedInUser) {

    for (User user : users) {
      queueTextMessages(
          groupId,
          user,
          sendTexts.getMessage() == null ? "" : sendTexts.getMessage(),
          sendTexts.getMediaURLs(),
          loggedInUser.trueUserId());
    }
  }

  @Async
  public void queueTextMessages(
      String messageGroupId,
      User user,
      String templateContent,
      List<URI> mediaURLs,
      Long loggedInUserId) {
    // dont try to send text if there is no phone number or the user doesnt have access
    if (null != user
        && user.getPhoneNumber() != null
        && user.getUserStatusType() != null
        && user.getHasAccess()) {
      try {
        final String template = renderTemplate(templateContent, Map.of("user", user));

        // make sure the sent by user id is the logged in user, not the user the content is getting
        // sent to
        smsService.queueMessage(
            messageGroupId,
            user.getId(),
            user.getPhoneNumber(),
            template,
            mediaURLs,
            RecipientType.USER,
            loggedInUserId);
      } catch (Exception ex) {
        log.error("MESSAGING: Error queueing SMS ", ex);
      }
    }
  }

  @Async
  public void queueTextMessagesForProject(
      String messageGroupId,
      Contact contact,
      String toPhone,
      String templateContent,
      List<URI> mediaURLs,
      Long sentByUserId) {
    try {
      final String template = renderTemplate(templateContent, Map.of("contact", contact));
      smsService.queueMessage(
          messageGroupId,
          contact.getId(),
          toPhone,
          template,
          mediaURLs,
          RecipientType.PROJECT,
          sentByUserId);
    } catch (Exception ex) {
      log.error("MESSAGING: Error queueing SMS ", ex);
    }
  }

  public String renderTemplate(String templateContent, Map<String, Object> contextMap)
      throws Exception {
    try (var output = new ByteArrayOutputStream()) {
      templatingEngineService.applyFreemarkerTemplate(templateContent, contextMap, output);
      return output.toString();
    }
  }

  public String getDefaultEmailTemplate() throws IOException {
    try (InputStream input =
        CommunicationService.class.getResourceAsStream("/communication/templates/email.ftl.txt")) {
      return new Scanner(input, "UTF-8").useDelimiter("\\A").next();
    }
  }

  public void sendPushNotificationToTopic(String title, String body)
      throws FirebaseMessagingException {
    Message message = Message.builder().putData("score", "854").setTopic("test").build();

    //    FirebaseMessaging.getInstance(app).subscribeToTopic(List.of("123"), "test");
    String response = firebaseMessaging.send(message);

    log.debug("SENT MESSAGE: {}", response);
  }
}
