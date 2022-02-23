package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.flow.model.EmailSender;
import com.albatross.api.v1.company.blueraven.services.EmailSenderService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/emailSender")
public class EmailSenderController {

    private EmailSenderService emailSenderService;

    @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<EmailSender> getEmailSenders() {
        return emailSenderService.getEmailSenders();
    }

    @PostMapping(value = "/saveEmailSenders")
    public void saveEmailSenders(@RequestBody List<EmailSender> emailSenders) {
        emailSenderService.saveEmailSenders(emailSenders);
    }

    @PutMapping(value = "/deleteEmailSenders")
    public void deleteEmailSenders(@RequestBody List<Long> emailSenderIds) {
        emailSenderService.deleteEmailSenders(emailSenderIds);
    }
}
