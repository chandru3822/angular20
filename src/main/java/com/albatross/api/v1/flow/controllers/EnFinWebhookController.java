package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.company.blueraven.services.EnFinService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping(value = "/webhook/enfin")
@RequiredArgsConstructor
public class EnFinWebhookController {

  private final String CONTRACT_SIGNED_EVENT = "PROJECT CONTRACT SIGNED";
  private final EnFinService enFinService;

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(value = "/webhook/event")
  public ResponseEntity handleEvent(@RequestBody EventWrapper eventWrapper) {
    String msg = "";
    if (eventWrapper.getApplicationId() == null) {
      msg = "ENFIN: Application ID is missing";
      log.error(msg);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
    }

    if (eventWrapper.getStatus().equals(CONTRACT_SIGNED_EVENT)) {
      try {
        msg = enFinService.updateFinancialAgreementSigned(eventWrapper.getApplicationId());
      } catch (Exception e) {
        msg = e.getMessage();
      }
    }
    else {
      return ResponseEntity.ok("Unsupported event type: " + eventWrapper.getStatus());
    }

    if (msg.isBlank()) {
      return ResponseEntity.ok("Financial Agreement Signed date successfully updated");
    }
    else {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
    }
  }

  @Data
  public static class EventWrapper {
    String status, applicationId, contractId;
  }
}
