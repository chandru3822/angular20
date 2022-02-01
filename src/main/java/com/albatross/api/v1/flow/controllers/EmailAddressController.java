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

    @GetMapping(value="/{companyId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<EmailSender> getEmailSenders( @PathVariable Long companyId) throws Exception {
        return mailService.getEmailSenders(companyId);
    }

    @PostMapping(value="/saveEmailAddress")
    public List<EmailSender> saveFromEmailAddress(@RequestBody EmailSender emailSenderAddress, @RequestParam boolean updateDefault) {
        return mailService.saveFromEmailAddress(emailSenderAddress, updateDefault);
    }

    @PutMapping(value="/updateEmailAddress")
    public List<EmailSender> updateSenderEmailAddress (@RequestBody EmailSender emailSenderAddress, @RequestParam boolean updateDefault) {
        return mailService.updateSenderEmailAddress(emailSenderAddress, updateDefault);
    }

    @PutMapping(value="/archiveEmailAddress")
    public void deleteFromEmailAddress(@RequestBody EmailSender emailSenderAddress) {
        mailService.deleteFromEmailAddress(emailSenderAddress.getId(), emailSenderAddress.getModifiedById());
    }
}
