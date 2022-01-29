package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.EmailSender;
import com.albatross.api.v1.flow.services.MailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/flow/emailAddress")
public class EmailAddressController {
    @Autowired
    private MailService mailService;

    @GetMapping(value="", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<EmailSender> getEmailSenders() throws Exception {
        return mailService.getEmailSenders();
    }

    @PostMapping(value="/saveEmailAddress")
    public void saveFromEmailAddress(@RequestBody EmailSender emailSenderAddress) {
        mailService.saveFromEmailAddress(emailSenderAddress);
    }

    @PutMapping(value="/updateEmailAddress")
    public List<EmailSender> updateSenderEmailAddress (@RequestBody EmailSender emailSenderAddress, @RequestParam boolean updateDefault) {
        return mailService.updateSenderEmailAddress(emailSenderAddress, updateDefault);
    }

    @PutMapping(value="/archiveEmailAddress")
    public void deleteFromEmailAddress(@RequestBody Long emailSenderId) {
        mailService.deleteFromEmailAddress(emailSenderId);
    }
}
