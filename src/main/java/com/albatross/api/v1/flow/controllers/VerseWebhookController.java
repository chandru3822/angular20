package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.VersusLeadEvent;
import com.albatross.api.v1.flow.services.VerseWebhookService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static org.apache.commons.lang3.StringUtils.isBlank;

@Slf4j
@RestController
@RequestMapping(value = "/webhook/verse")
@RequiredArgsConstructor
public class VerseWebhookController {

    private final VerseWebhookService verseWebhookService;

    @ResponseStatus(HttpStatus.ACCEPTED)
    @PostMapping(value = "/contact")
    public ResponseEntity updateContactLeadStatus(@RequestBody VersusLeadEvent versusLeadEvent) throws Exception {
      String msg;
      if (versusLeadEvent.getExternalLeadId() == null) {
          msg = "VERSE: External Lead ID is missing";
          log.error(msg);
          return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
      }

      log.debug(
          "VERSE: Received new lead event from Verse. " +
              "externalLeadId: {}, " +
              "event: {}, " +
              "title: {} ",
              versusLeadEvent.getExternalLeadId() != null ? versusLeadEvent.getExternalLeadId() : "null",
              !isBlank(versusLeadEvent.getEvent()) ? versusLeadEvent.getEvent() : "null",
              !isBlank(versusLeadEvent.getTitle()) ? versusLeadEvent.getTitle() : "null"
      );

      return verseWebhookService.updateContactLeadStatus(versusLeadEvent);
    }
}
