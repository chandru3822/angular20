package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.SendTextsRequest;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CommunicationService;
import com.albatross.api.v1.flow.services.ContactService;
import com.albatross.api.v1.flow.services.SMSService;
import com.albatross.api.v1.flow.services.UserService;
import com.google.common.collect.Maps;
import com.google.i18n.phonenumbers.NumberParseException;
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
import java.util.function.Predicate;
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
  private final UserService userService;
  private final SecurityService securityService;

  @GetMapping(value = "/defaultEmailTemplate", produces = "text/html")
  public String getDefaultEmailTemplate() throws Exception {
    return communicationService.getDefaultEmailTemplate();
  }

  @PostMapping(value = "/sendTextsForProject")
  public Map<String, Object> sendTextsForProject(@RequestBody SendTextsRequest sendTexts) {
    User user = securityService.getCurrentUser();
    String groupId = UUID.randomUUID().toString();
    Long contactId = sendTexts.getUserIDs().get(0);
    Contact contact = contactService.getContact(contactId);
    log.debug("TWILIO: attempting text for contact ID: {}", contactId);
    String phoneNumber = contact.getMobile() != null ? contact.getMobile() : contact.getPhone();
    try {
      String safePhone = smsService.safeCleanPhoneNumber(phoneNumber);
      communicationService.queueTextMessagesForProject(
          groupId,
          contact,
          safePhone,
          sendTexts.getMessage() == null ? "" : sendTexts.getMessage(),
          sendTexts.getMediaURLs(),
          user.getId());

      return Map.of("messageGroup", groupId);
    } catch (NumberParseException ex) {
      log.warn("TWILIO: Message not sent: Invalid phone number: {}", phoneNumber);
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Invalid phone number: " + phoneNumber, new Exception());
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

  @ExceptionHandler({IllegalArgumentException.class})
  public ResponseEntity handleException(HttpServletRequest req, Exception e) {
    return ResponseEntity.badRequest().body(e.getMessage());
  }
}
