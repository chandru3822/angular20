package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.company.blueraven.services.GoodleapService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping(value = "/webhook/goodleap")
@RequiredArgsConstructor
public class GoodLeapWebhookController {

  private final GoodleapService goodleapService;

  private final String CONTRACT_SIGNED_EVENT = "ContractSigned";

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(value = "/webhook/event")
  public ResponseEntity handleEvent(@RequestBody EventWrapper eventWrapper) {
    String msg = "";
    if (eventWrapper.getReferenceNumber() == null) {
      msg = "GOODLEAP: Reference Number is missing";
      log.error(msg);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
    }

    if (eventWrapper.getEvent().equals(CONTRACT_SIGNED_EVENT)) {
      try {
        goodleapService.updateFinancialAgreementSignedValue(Long.parseLong(eventWrapper.getReferenceNumber()),
                                                          eventWrapper.getTimestamp());
      } catch (Exception e) {
        msg = e.getMessage();
      }
    }
    else {
      return ResponseEntity.ok("Unsupported event type: " + eventWrapper.getEvent());
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
    String event, applicationId, timestamp, referenceNumber;
  }
}
