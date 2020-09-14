package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.SendEmailsRequest;
import com.albatross.api.v1.flow.model.SendTextsRequest;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CommunicationService;
import com.albatross.api.v1.flow.services.ContactService;
import com.albatross.api.v1.flow.services.UserService;

import com.google.common.collect.Maps;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.activation.FileDataSource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.*;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/communication")
public class CommunicationController {

    @Autowired
    private CommunicationService communicationService;

    @Autowired
    private ContactService contactService;

    @Autowired
    private UserService userService;

    @GetMapping(value = "/defaultEmailTemplate", produces = "text/html")
    public String getDefaultEmailTemplate() throws Exception {
        return communicationService.getDefaultEmailTemplate();
    }

    @PostMapping(value = "/sendTextsForProject")
    public HashMap<String, Object> sendTextsForProject(@RequestBody SendTextsRequest sendTexts) {
        String groupId = UUID.randomUUID().toString();
        Long contactId = sendTexts.getUserIDs().get(0);
        communicationService.queueTextMessagesForProject(groupId, contactService.getContact(contactId),
            sendTexts.getMessage() == null ? "" : sendTexts.getMessage(), sendTexts.getMediaURLs());

        return new HashMap<String, Object>() {{
            put("messageGroup", groupId);
        }};
    }

    @PostMapping(value = "/sendTexts")
    public HashMap<String, Object> sendTexts(@RequestBody SendTextsRequest sendTexts) {
        String groupId = UUID.randomUUID().toString();

        for (Long userID : sendTexts.getUserIDs()) {
            Optional<User> user = userService.getUser(userID);
            communicationService.queueTextMessages(groupId, user, sendTexts.getMessage() == null ? "" : sendTexts.getMessage(), sendTexts.getMediaURLs());
        }

        return new HashMap<String, Object>() {{
            put("messageGroup", groupId);
        }};
    }

    @ResponseStatus(HttpStatus.OK)
    @PostMapping(value = "/sendEmails",
                    consumes = {"multipart/form-data"})
    public void sendEmails(
            @RequestPart(name = "data") SendEmailsRequest body,
            @RequestPart(name = "attachments", required = false) List<MultipartFile> attachments,
            HttpServletRequest request) throws Exception {

        Map<String, File> temporaryFiles = new HashMap<>();
        try {
            for (MultipartFile attachment : attachments) {
                File tempFile = File.createTempFile(attachment.getName(), Long.toString(System.nanoTime()));
                try (InputStream fileInput = attachment.getInputStream(); FileOutputStream fileOutput = new FileOutputStream(tempFile)) {
                    IOUtils.copy(fileInput, fileOutput);
                }
                temporaryFiles.put(attachment.getOriginalFilename(), tempFile);
            }
            communicationService.sendEmails(body.getSubject(), body.getUserIds(), body.getTemplate(),
                    Maps.transformValues(temporaryFiles, FileDataSource::new),
                    getUnsubscribeURLForEmails(request),
                    body.getFrom());
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
                    "SalesOps@blueravensolar.com");
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
