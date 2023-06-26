package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.SendTextsRequest;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.services.*;
import com.google.common.collect.Maps;
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
import java.util.*;
import java.util.concurrent.Future;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import static java.util.function.Predicate.not;

@Slf4j
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

  @PostMapping(value = "/sendTextsForProject/{projectId}")
  public Map<String, Object> sendTextsForProject(
      @PathVariable Long projectId, @RequestBody SendTextsRequest sendTexts) {
    User user = securityService.getCurrentUser();

    Long contactId = 0L;
    if (sendTexts.getUserIDs() == null || sendTexts.getUserIDs().isEmpty()) {
      Optional<Project> project = projectService.getProject(projectId);
      if (project.isPresent()) {
        contactId = project.get().getContactId();
      }
    }
    else {
      contactId = sendTexts.getUserIDs().get(0);
    }

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

  @PostMapping(value = "/sendTextsForUser/{userId}")
  public Map<String, Object> sendTextsForUser(
    @PathVariable Long userId, @RequestBody SendTextsRequest sendTexts) {
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
  public Map<String, String> sendTexts(@RequestBody SendTextsRequest sendTexts)  {
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
