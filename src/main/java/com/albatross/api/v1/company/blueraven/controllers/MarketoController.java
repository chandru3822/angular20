package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.BrsProcessStepActionFunctionService;
import com.albatross.api.v1.company.blueraven.services.MarketoService;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.services.ContactService;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.Future;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/marketo", produces = MediaType.APPLICATION_JSON_VALUE)
public class MarketoController {

    private final MarketoService marketoService;

    private final ContactService contactService;

    private final BrsProcessStepActionFunctionService brsProcessStepActionFunctionService;

    @SneakyThrows
    @GetMapping(value = "/lead")
    public Contact getLead() {
        Future<Long> contactId = marketoService.getContactIdByProjectId(1234L);
        return contactService.getContact(contactId.get());
    }

    @GetMapping(value = "/pushLead")
    public ResponseEntity<Void> pushLead() {
        brsProcessStepActionFunctionService.pushContactToMarketo(contactService.getContact(1234L));
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
