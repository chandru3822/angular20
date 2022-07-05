package com.albatross.api.v1.flow.controllers;

import com.albatross.api.exception.ApiException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.SendTextsRequest;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.services.*;
import com.google.common.collect.Maps;
import com.google.i18n.phonenumbers.NumberParseException;
import freemarker.core.InvalidReferenceException;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import javax.activation.FileDataSource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.function.Predicate;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static java.util.function.Predicate.not;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/communication")
public class CommunicationController {

  private final CommunicationService communicationService;
  private final SMSService smsService;
  private final ContactService contactService;
  private final ProjectService projectService;
  private final ProjectProcessStepService projectProcessStepService;
  private final ProjectProcessStepEventService projectProcessStepEventService;
  private final UserService userService;
  private final SecurityService securityService;

  @GetMapping(value = "/defaultEmailTemplate", produces = "text/html")
  public String getDefaultEmailTemplate() throws Exception {
    return communicationService.getDefaultEmailTemplate();
  }

  @PostMapping(value = "/sendTextsForProject/{projectId}")
  public Map<String, Object> sendTextsForProject(
      @PathVariable Long projectId, @RequestBody SendTextsRequest sendTexts) {
    User user = securityService.getCurrentUser();
    String groupId = UUID.randomUUID().toString();
    Long contactId = sendTexts.getUserIDs().get(0);
    Contact contact = contactService.getContact(contactId);
    log.debug("TWILIO: attempting text for contact ID: {}", contactId);
    if (null != contact) {
      String phoneNumber = contact.getMobile() != null ? contact.getMobile() : contact.getPhone();
      try {
        String safePhone = smsService.safeCleanPhoneNumber(phoneNumber);
        Optional<Project> projectIn = projectService.getProject(projectId);
        if (projectIn.isEmpty()) {
          log.error("MESSAGING: Missing project id={}", projectId);
          throw new ApiException("Unable to find project");
        }
        Project project = projectIn.get();

        ProjectDetails projectDetails = getProjectTemplateFields(projectId, project.getTimeZone());

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
            communicationService.renderTemplate(
                sendTexts.getMessage() == null ? "" : sendTexts.getMessage(), contextMap);

        communicationService.queueTextMessagesForProject(
            groupId,
            contact,
            projectId,
            safePhone,
            template,
            sendTexts.getMediaURLs(),
            user.getId());

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
    } else {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Could not find contact for contact id: " + contactId,
          new Exception());
    }
  }

  @PostMapping(value = "/sendTexts")
  public Map<String, String> sendTexts(@RequestBody SendTextsRequest sendTexts) {
    User currentUser = securityService.getCurrentUser();

    String groupId = UUID.randomUUID().toString();
    final List<User> users = userService.findByIds(sendTexts.getUserIDs());
    communicationService.sendMassText(groupId, sendTexts, users, currentUser);
    return Map.of("messageGroup", groupId);
  }

  @ResponseStatus(HttpStatus.OK)
  @PostMapping(value = "/sendEmails")
  public Map<String, Object> sendEmails(
      @RequestParam String from,
      @RequestParam String subject,
      @RequestParam String template,
      @RequestParam List<Long> userIds,
      @RequestParam(required = false) List<MultipartFile> attachments,
      HttpServletRequest request)
      throws Exception {

    User currentUser = securityService.getCurrentUser();
    Map<String, File> temporaryFiles = new HashMap<>();

    if (null != attachments) {
      for (MultipartFile attachment : attachments) {
        File tempFile = File.createTempFile(attachment.getName(), Long.toString(System.nanoTime()));

        try (InputStream fileInput = attachment.getInputStream();
            FileOutputStream fileOutput = new FileOutputStream(tempFile)) {
          IOUtils.copy(fileInput, fileOutput);
        }
        temporaryFiles.put(attachment.getOriginalFilename(), tempFile);
      }
    }

    final URL unsubscribeURLForEmails = getUnsubscribeURLForEmails(request);
    final List<User> users = userService.findByIds(userIds);

    communicationService.sendBulkEmail(
        subject,
        template,
        temporaryFiles,
        unsubscribeURLForEmails,
        users,
        from,
        "Blue Raven Sales Operation",
        currentUser.trueUserId());

    final Predicate<User> userStatusTypePredicate = u -> u.getUserStatusType() == null;
    final Map<Boolean, List<User>> collect =
        users.stream()
            .collect(
                Collectors.partitioningBy(userStatusTypePredicate.or(not(User::getHasAccess))));

    final List<User> usersQueued = collect.getOrDefault(Boolean.FALSE, List.of());
    final List<User> usersExcluded = collect.getOrDefault(Boolean.TRUE, List.of());

    return Map.of(
        "queued",
        usersQueued.size(),
        "excluded",
        usersExcluded.stream().map(u -> Map.of("id", u.getId(), "name", u.getFullName())));
  }

  @PostMapping(value = "/sendSingleEmail", produces = "text/html")
  public void sendEmailTest(
      @RequestParam(name = "userID") Long userID,
      @RequestParam(name = "emailAddress") String emailAddress,
      @RequestParam(name = "subject") String subject,
      @RequestPart("template") String templateContent,
      @RequestPart("attachments") List<MultipartFile> attachments,
      HttpServletRequest request,
      HttpServletResponse response)
      throws Exception {

    Map<String, File> temporaryFiles = new HashMap<>();
    try {

      for (MultipartFile attachment : attachments) {
        File tempFile = File.createTempFile(attachment.getName(), Long.toString(System.nanoTime()));
        try (InputStream fileInput = attachment.getInputStream();
            FileOutputStream fileOutput = new FileOutputStream(tempFile)) {
          IOUtils.copy(fileInput, fileOutput);
        }
        temporaryFiles.put(attachment.getOriginalFilename(), tempFile);
      }

      User user = userService.findUserById(userID);

      communicationService.sendEmail(
          subject,
          emailAddress,
          user,
          templateContent,
          Maps.transformValues(temporaryFiles, FileDataSource::new),
          getUnsubscribeURLForEmails(request),
          "SalesOps@blueravensolar.com",
          "Blue Raven Sales Operation",
          user.trueUserId());

    } finally {
      for (File temporaryFile : temporaryFiles.values()) {
        if (temporaryFile.exists()) {
          temporaryFile.delete();
        }
      }
    }
  }

  private URL getUnsubscribeURLForEmails(HttpServletRequest request) throws Exception {
    return new URL(
        request.getScheme()
            + "://"
            + request.getServerName()
            + ":"
            + request.getServerPort()
            + request.getContextPath()
            + "/api/v1/user/emailoptOut");
  }

  private ProjectDetails getProjectTemplateFields(Long projectId, String projectTimeZone) {
    ProjectDetails projectDetails = projectService.getProjectDetailTemplateFields(projectId);

    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss[.n]");
    if (projectTimeZone != null && !projectTimeZone.isEmpty()) {
      String closerAppointmentTime = "";
      String ahjInspectionTime = "";
      String installationStartDate = "";
      String installationStartTime = "";
      String installationLatestStartTime = "";
      String installationEndTime = "";
      LocalDateTime timestampFunctionResult;
      ZonedDateTime zoneTimestampFunctionResult;

      if (projectDetails.getLocalCloserAppointmentStartTime() != null) {
        timestampFunctionResult = LocalDateTime.parse(projectDetails.getLocalCloserAppointmentStartTime(), dateTimeFormatter);
        zoneTimestampFunctionResult =
          timestampFunctionResult
            .atZone(ZoneId.of("UTC"))
            .withZoneSameInstant(ZoneId.of(projectTimeZone));
        closerAppointmentTime =
          zoneTimestampFunctionResult.format(DateTimeFormatter.ofPattern("MM/dd/yyyy h:mm a"));
        projectDetails.setLocalCloserAppointmentStartTime(closerAppointmentTime);
      }

      if (projectDetails.getAhjInspectionWorkStartTime() != null) {
        timestampFunctionResult = LocalDateTime.parse(projectDetails.getAhjInspectionWorkStartTime(), dateTimeFormatter);
        zoneTimestampFunctionResult =
          timestampFunctionResult
            .atZone(ZoneId.of("UTC"))
            .withZoneSameInstant(ZoneId.of(projectTimeZone));
        ahjInspectionTime =
          zoneTimestampFunctionResult.format(DateTimeFormatter.ofPattern("MM/dd/yyyy h:mm a"));
        projectDetails.setAhjInspectionWorkStartTime(ahjInspectionTime);
      }

      if (projectDetails.getInstallationStartTime() != null) {
        LocalDateTime timestampFunctionStartTimeResult = LocalDateTime.parse(projectDetails.getInstallationStartTime(), dateTimeFormatter);
        ZonedDateTime zoneStartTimestampFunctionResult =
          timestampFunctionStartTimeResult
            .atZone(ZoneId.of("UTC"))
            .withZoneSameInstant(ZoneId.of(projectTimeZone));
        installationStartDate =
          zoneStartTimestampFunctionResult.format(DateTimeFormatter.ofPattern("MM/dd/yyyy"));
        installationStartTime =
          zoneStartTimestampFunctionResult.format(DateTimeFormatter.ofPattern("h:mm a"));
        zoneStartTimestampFunctionResult = zoneStartTimestampFunctionResult.plusHours(1L);
        installationLatestStartTime =
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
        installationEndTime =
          zoneEndTimestampFunctionResult.format(DateTimeFormatter.ofPattern("MM/dd/yyyy h:mm a"));
        projectDetails.setInstallationEndTime(installationEndTime);
      }

    }

    Optional<String> scopeOfWork =
      projectProcessStepService.getInstallationScopeOfWork(projectId);

    if (scopeOfWork.isPresent()) {
      projectDetails.setInstallationScopeOfWork(scopeOfWork.get());
    }

    return projectDetails;
  }

  @ExceptionHandler({IllegalArgumentException.class})
  public ResponseEntity handleException(HttpServletRequest req, Exception e) {
    return ResponseEntity.badRequest().body(e.getMessage());
  }

  @Data
  public static class ProjectDetails {
    private String primaryFinancier,
        localCloserAppointmentStartTime,
        ahjInspectionWorkStartTime,
        installationDate,
        installationStartTime,
        installationLatestStartTime,
        installationEndTime,
        installationScopeOfWork;
  }
}
