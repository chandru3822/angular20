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
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
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
import java.io.OutputStream;
import java.net.URL;
import java.util.*;
import java.util.concurrent.Future;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/communication")
public class CommunicationController {

    @Autowired
    private CommunicationService communicationService;

    @Autowired
    private SMSService smsService;

    @Autowired
    private ContactService contactService;

    @Autowired
    private UserService userService;

    @Autowired
    private SecurityService securityService;

    @GetMapping(value = "/defaultEmailTemplate", produces = "text/html")
    public String getDefaultEmailTemplate() throws Exception {
        return communicationService.getDefaultEmailTemplate();
    }

    @PostMapping(value = "/sendTextsForProject")
    public HashMap<String, Object> sendTextsForProject(@RequestBody SendTextsRequest sendTexts) {
        User user = securityService.getCurrentUser();
        String groupId = UUID.randomUUID().toString();
        Long contactId = sendTexts.getUserIDs().get(0);
        Contact contact = contactService.getContact(contactId);
        log.info("TWILIO: attempting text for contact ID: {}", contactId);
        String phoneNumber = contact.getMobile() != null ? contact.getMobile() : contact.getPhone();
        try {
          String safePhone = smsService.safeCleanPhoneNumber(phoneNumber);
          communicationService.queueTextMessagesForProject(groupId, contact, safePhone,
              sendTexts.getMessage() == null ? "" : sendTexts.getMessage(), sendTexts.getMediaURLs(), user.getId());

          return new HashMap<String, Object>() {{
              put("messageGroup", groupId);
          }};
        } catch (NumberParseException ex) {
          log.warn("TWILIO: Message not sent: Invalid phone number: {}", phoneNumber);
          throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid phone number: " + phoneNumber, new Exception());
        }
    }

    @PostMapping(value = "/sendTexts")
    public HashMap<String, Object> sendTexts(@RequestBody SendTextsRequest sendTexts) {
      User currentUser = securityService.getCurrentUser();

      String groupId = UUID.randomUUID().toString();

         for (Long userID : sendTexts.getUserIDs()) {
            Optional<User> user = userService.getUser(userID, false);
            communicationService.queueTextMessages(groupId, user, sendTexts.getMessage() == null ? "" : sendTexts.getMessage(), sendTexts.getMediaURLs(), currentUser.trueUserId());
        }

        return new HashMap<String, Object>() {{
            put("messageGroup", groupId);
        }};
    }

    @ResponseStatus(HttpStatus.OK)
    @PostMapping(value = "/sendEmails")
    public void sendEmails(
        @RequestParam String from,
        @RequestParam String subject,
        @RequestParam String template,
        @RequestParam List<Long> userIds,
        @RequestParam(required = false) List<MultipartFile> attachments,
        HttpServletRequest request) throws Exception {

        Map<String, File> temporaryFiles = new HashMap<>();
        try {
            if(null != attachments) {
              for (MultipartFile attachment: attachments) {
                  File tempFile = File.createTempFile(attachment.getName(), Long.toString(System.nanoTime()));
                  try (InputStream fileInput = attachment.getInputStream(); FileOutputStream fileOutput = new FileOutputStream(tempFile)) {
                      IOUtils.copy(fileInput, fileOutput);
                  }
                  temporaryFiles.put(attachment.getOriginalFilename(), tempFile);
              }
            }

            try {
                for (Long userId: userIds) {
                    Optional<User> user = userService.getUser(userId, false);
                    //do not send email if they do not have access to the system
                    if (user.isPresent() && user.get().getUserStatusType() != null && user.get().getHasAccess()) {
                        Future<Void> future = communicationService.sendEmail(subject, user.get().getEmail(), user.get(),
                            template, Maps.transformValues(temporaryFiles, FileDataSource::new),
                            getUnsubscribeURLForEmails(request), from, "Blue Raven Sales Operation");

                        future.get();
                    }
                }
            } catch (Exception e) {
                log.error("EMAIL" + e.getMessage());
            }
        } finally {
            // delete temp files
            for (File tempFile : temporaryFiles.values()) {
                if (tempFile.exists())
                    tempFile.delete();
            }
        }
    }

    @PostMapping(value = "/sendSingleEmail", produces = "text/html")
    public void sendEmailTest(
            @RequestParam(name = "userID") Long userID,
            @RequestParam(name = "emailAddress") String emailAddress,
            @RequestParam(name = "subject") String subject,
            @RequestPart("template") String templateContent,
            @RequestPart("attachments") List<MultipartFile> attachments,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        Map<String, File> temporaryFiles = new HashMap<>();
        try (OutputStream output = response.getOutputStream()) {

            for (MultipartFile attachment : attachments) {
                File tempFile = File.createTempFile(attachment.getName(), Long.toString(System.nanoTime()));
                try (InputStream fileInput = attachment.getInputStream(); FileOutputStream fileOutput = new FileOutputStream(tempFile)) {
                    IOUtils.copy(fileInput, fileOutput);
                }
                temporaryFiles.put(attachment.getOriginalFilename(), tempFile);
            }

            User user = userService.findUserById(userID);

            communicationService.sendEmail(subject, emailAddress, user, templateContent,
                    Maps.transformValues(temporaryFiles, FileDataSource::new),
                    getUnsubscribeURLForEmails(request),
                    "SalesOps@blueravensolar.com", "Blue Raven Sales Operation");
        } finally {
            for (File temporaryFile : temporaryFiles.values()) {
                if (temporaryFile.exists()) {
                    temporaryFile.delete();
                }
            }
        }
    }

    private URL getUnsubscribeURLForEmails(HttpServletRequest request) throws Exception {
        return new URL(request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/api/v1/user/emailoptOut");
    }

    @ExceptionHandler({ IllegalArgumentException.class })
    public ResponseEntity handleException(HttpServletRequest req, Exception e) {
        return ResponseEntity.badRequest()
                             .body(e.getMessage());
    }
}
