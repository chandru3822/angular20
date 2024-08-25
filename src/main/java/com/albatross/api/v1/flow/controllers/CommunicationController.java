package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.SendTextsRequest;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.services.CommunicationService;
import com.albatross.api.v1.flow.services.ContactService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.albatross.api.v1.flow.services.UserService;
import com.google.common.collect.Maps;
import jakarta.activation.FileDataSource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.*;
import java.util.concurrent.Future;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import static java.util.function.Predicate.not;

@Slf4j
@Validated
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/communication")
public class CommunicationController {

  private final CommunicationService communicationService;
  private final ContactService contactService;
  private final ProjectService projectService;
  private final UserService userService;
  private final SecurityService securityService;

  @GetMapping(value = "/defaultEmailTemplate", produces = "text/html")
  public String getDefaultEmailTemplate() throws Exception {
    return communicationService.getDefaultEmailTemplate();
  }

  @Data
  public static class SendTextProjectRequest {
    List<Long> userIDs;
    @Size(max = 1600, message = "Message must be less than 1600 characters")
    String message = "";
    List<URI> mediaURLs = new ArrayList<>();
    Long smsTeamId;
  }

  @PostMapping(value = "/sendTextsForProject/{projectId}")
  public Map<String, Object> sendTextsForProject(
    @PathVariable Long projectId, @RequestBody @Valid SendTextProjectRequest sendTexts) {
    User user = securityService.getCurrentUser();

    Long contactId = 0L;
    Optional<Project> project = projectService.getProject(projectId);
    if(project.isPresent()) {
      contactId = project.get().getContactId();
    }
//    if (sendTexts.getUserIDs() == null || sendTexts.getUserIDs().isEmpty()) {
//      if (project.isPresent()) {
//        contactId = project.get().getContactId();
//      }
//    }
//    else {
//      contactId = sendTexts.getUserIDs().get(0);
//    }

    Contact contact = contactService.getContact(contactId);
    log.debug("TWILIO: attempting text for contact ID: {}", contactId);
    if (null != contact) {
      return communicationService.sendTextsForProject(projectId, contact, user, sendTexts.getMessage(), sendTexts.getMediaURLs(), sendTexts.getSmsTeamId());
    } else {
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Could not find contact for contact id: " + contactId,
        new Exception());
    }
  }

  @Data
  public static class SendTextUserRequest {
    @Size(max = 1600, message = "Message must be less than 1600 characters")
    String message = "";
    List<URI> mediaURLs = new ArrayList<>();
    Long smsTeamId;
  }

  @PostMapping(value = "/sendTextsForUser/{userId}")
  public Map<String, Object> sendTextsForUser(
    @PathVariable Long userId, @RequestBody @Valid SendTextUserRequest sendTexts) {
    Optional<User> recipientUser = userService.getUser(userId, false);
    log.debug("TWILIO: attempting text for user ID: {}", userId);

    if (recipientUser.isPresent()) {
      return communicationService.sendTextsForUser(recipientUser.get(), sendTexts.getMessage(), sendTexts.getMediaURLs(), sendTexts.getSmsTeamId());
    } else {
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Could not find user for user id: " + userId,
        new Exception());
    }
  }

  @PostMapping(value = "/sendTexts")
  public Map<String, String> sendTexts(@RequestBody @Valid SendTextsRequest sendTexts) {
    User currentUser = securityService.getCurrentUser();

    String groupId = UUID.randomUUID().toString();
    final List<User> users = userService.findByIds(sendTexts.getUserIDs());
    Future<Void> future = communicationService.sendMassText(groupId, sendTexts, users, currentUser);
    try {
      future.get();
      return Map.of("messageGroup", groupId);
    } catch (Exception e) {
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        e.getMessage(),
        new Exception());
    }
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
      currentUser.trueUserId(),
      null,
      null);

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
    @RequestParam Long userID,
    @RequestParam String emailAddress,
    @RequestParam String subject,
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
        user.trueUserId(),
        null);

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

  @ExceptionHandler({IllegalArgumentException.class})
  public ResponseEntity handleException(HttpServletRequest req, Exception e) {
    return ResponseEntity.badRequest().body(e.getMessage());
  }

  @Data
  public static class ProjectDetails {
    private String primaryFinancier,
      localCloserAppointmentStartTime,
      localCloserAppointmentStartDate,
      ahjInspectionWorkDate,
      ahjInspectionWorkStartTime,
      installationDate,
      installationStartTime,
      installationLatestStartTime,
      installationEndTime,
      installationScopeOfWork;
  }
}
