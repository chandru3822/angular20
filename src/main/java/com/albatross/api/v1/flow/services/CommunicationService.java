package com.albatross.api.v1.flow.services;

import com.albatross.api.exception.ApiException;
import com.albatross.api.v1.flow.controllers.CommunicationController;
import com.albatross.api.v1.flow.enums.RecipientType;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.SendTextsRequest;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.project.Project;
import com.google.common.collect.Maps;
import com.google.i18n.phonenumbers.NumberParseException;
import freemarker.core.InvalidReferenceException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.activation.DataSource;
import javax.activation.FileDataSource;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.Future;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class CommunicationService {

  private final TemplatingEngineService templatingEngineService;
  private final UserService userService;
  private final MailService mailService;
  private final SMSService smsService;
  private final ProjectService projectService;

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
                      return new EmailMessage(
                          user.getEmail(),
                          sentByEmail,
                          sentByName,
                          subject,
                          message,
                          sentByUserId,
                          true,
                          null);
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
            null,
          null,
            user.getPhoneNumber(),
            template,
            mediaURLs,
            RecipientType.USER,
            loggedInUserId,
            null);
      } catch (Exception ex) {
        log.error("MESSAGING: Error queueing SMS ", ex);
      }
    }
  }

  @Async
  public void queueTextMessagesForProject (
      String messageGroupId,
      Contact contact,
      Long projectId,
      String toPhone,
      String template,
      List<URI> mediaURLs,
      Long sentByUserId,
      Long sentBySmsTeamId) {
    try {
      smsService.queueMessage(
        messageGroupId,
        null,
        contact.getId(),
        projectId,
        toPhone,
        template,
        mediaURLs,
        RecipientType.PROJECT,
        sentByUserId,
        sentBySmsTeamId);
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

  public Map<String, Object> sendTextsForProject(Long projectId, Contact contact, User user, String message, List<URI> mediaURLs, Long smsTeamId) {
    String groupId = UUID.randomUUID().toString();
      String phoneNumber = (contact.getMobile() != null && !contact.getMobile().isEmpty()) ? contact.getMobile() : contact.getPhone();
      try {
        String safePhone = smsService.safeCleanPhoneNumber(phoneNumber);
        Optional<Project> projectIn = projectService.getProject(projectId);
        if (projectIn.isEmpty()) {
          log.error("MESSAGING: Missing project id={}", projectId);
          throw new ApiException("Unable to find project");
        }
        Project project = projectIn.get();

        CommunicationController.ProjectDetails projectDetails = getProjectTemplateFields(projectId, project.getTimeZone());

        Map<String, Object> contextMap =
          Map.of(
            "contact",
            contact,
            "project",
            project,
            "user",
            user,
            "projectDetails",
            projectDetails);

        String template =
          renderTemplate(
            message == null ? "" : message, contextMap);

        queueTextMessagesForProject(
          groupId,
          contact,
          projectId,
          safePhone,
          template,
          mediaURLs,
          user.getId(),
          smsTeamId);

        return Map.of("messageGroup", groupId);
      } catch (NumberParseException ex) {
        log.warn("TWILIO: Message not sent: Invalid phone number: {}", phoneNumber);
        throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Invalid phone number: " + phoneNumber, new Exception());
      } catch (InvalidReferenceException ire) {
        Pattern invalidParameter = Pattern.compile("([$]\\S+)");
        Matcher m = invalidParameter.matcher(ire.getMessage());
        if (m.find()) {
          String invalidParamName = m.group(1);
          throw new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "Invalid parameter " + invalidParamName + " ",
            new Exception());
        } else {
          throw new ResponseStatusException(
            HttpStatus.BAD_REQUEST, "Invalid parameter: " + ire.getMessage(), new Exception());
        }
      } catch (Exception e) {
        log.error("MESSAGING: Error queueing SMS message ", e);
        throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Error queueing message: " + e.getMessage(), new Exception());
      }
  }

  private CommunicationController.ProjectDetails getProjectTemplateFields(Long projectId, String projectTimeZone) {
    CommunicationController.ProjectDetails projectDetails = projectService.getProjectDetailTemplateFields(projectId);

    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss[.n]");
    if (projectTimeZone != null && !projectTimeZone.isEmpty()) {
      LocalDateTime timestampFunctionResult;
      ZonedDateTime zoneTimestampFunctionResult;

      if (projectDetails.getLocalCloserAppointmentStartTime() != null) {
        timestampFunctionResult = LocalDateTime.parse(projectDetails.getLocalCloserAppointmentStartTime(), dateTimeFormatter);
        zoneTimestampFunctionResult =
          timestampFunctionResult
            .atZone(ZoneId.of("UTC"))
            .withZoneSameInstant(ZoneId.of(projectTimeZone));
        String closerAppointmentTime =
          zoneTimestampFunctionResult.format(DateTimeFormatter.ofPattern("h:mm a"));
        String closerAppointmentDate =
          zoneTimestampFunctionResult.format(DateTimeFormatter.ofPattern("MM/dd/yyyy"));
        projectDetails.setLocalCloserAppointmentStartTime(closerAppointmentTime);
        projectDetails.setLocalCloserAppointmentStartDate(closerAppointmentDate);
      }

      if (projectDetails.getAhjInspectionWorkStartTime() != null) {
        timestampFunctionResult = LocalDateTime.parse(projectDetails.getAhjInspectionWorkStartTime(), dateTimeFormatter);
        zoneTimestampFunctionResult =
          timestampFunctionResult
            .atZone(ZoneId.of("UTC"))
            .withZoneSameInstant(ZoneId.of(projectTimeZone));
        String ahjInspectionDate =
          zoneTimestampFunctionResult.format(DateTimeFormatter.ofPattern("MM/dd/yyyy"));
        String ahjInspectionTime =
          zoneTimestampFunctionResult.format(DateTimeFormatter.ofPattern("h:mm a"));
        projectDetails.setAhjInspectionWorkDate(ahjInspectionDate);
        projectDetails.setAhjInspectionWorkStartTime(ahjInspectionTime);
      }

      if (projectDetails.getInstallationStartTime() != null) {
        LocalDateTime timestampFunctionStartTimeResult = LocalDateTime.parse(projectDetails.getInstallationStartTime(), dateTimeFormatter);
        ZonedDateTime zoneStartTimestampFunctionResult =
          timestampFunctionStartTimeResult
            .atZone(ZoneId.of("UTC"))
            .withZoneSameInstant(ZoneId.of(projectTimeZone));
        String installationStartDate =
          zoneStartTimestampFunctionResult.format(DateTimeFormatter.ofPattern("MM/dd/yyyy"));
        String installationStartTime =
          zoneStartTimestampFunctionResult.format(DateTimeFormatter.ofPattern("h:mm a"));
        zoneStartTimestampFunctionResult = zoneStartTimestampFunctionResult.plusHours(1L);
        String installationLatestStartTime =
          zoneStartTimestampFunctionResult.format(DateTimeFormatter.ofPattern("h:mm a"));
        projectDetails.setInstallationDate(installationStartDate);
        projectDetails.setInstallationStartTime(installationStartTime);
        projectDetails.setInstallationLatestStartTime(installationLatestStartTime);
      }


      if (projectDetails.getInstallationEndTime() != null) {
        LocalDateTime timestampFunctionEndTimeResult =
          LocalDateTime.parse(projectDetails.getInstallationEndTime(), dateTimeFormatter);
        ZonedDateTime zoneEndTimestampFunctionResult =
          timestampFunctionEndTimeResult
            .atZone(ZoneId.of("UTC"))
            .withZoneSameInstant(ZoneId.of(projectTimeZone));
        String installationEndTime =
          zoneEndTimestampFunctionResult.format(DateTimeFormatter.ofPattern("MM/dd/yyyy h:mm a"));
        projectDetails.setInstallationEndTime(installationEndTime);
      }

    }

    Optional<String> scopeOfWork = projectService.getInstallationScopeOfWork(projectId);

    if (scopeOfWork.isPresent()) {
      projectDetails.setInstallationScopeOfWork(scopeOfWork.get());
    }

    return projectDetails;
  }

  //  public void sendPushNotificationToTopic(String title, String body)
  //      throws FirebaseMessagingException {
  //    Message message = Message.builder().putData("score", "854").setTopic("test").build();
  //
  //    //    FirebaseMessaging.getInstance(app).subscribeToTopic(List.of("123"), "test");
  //    String response = firebaseMessaging.send(message);
  //
  //    log.debug("SENT MESSAGE: {}", response);
  //  }
}
