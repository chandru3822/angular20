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

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(value = "/contractSigned")
  public ResponseEntity updateContractSignedDate(@RequestBody ContractSignedEvent contractSignedEvent) {
    String msg;
    if (contractSignedEvent.getReferenceNumber() == null) {
      msg = "GOODLEAP: Application ID is missing";
      log.error(msg);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
    }

    /*log.debug(
        "GOODLEAP: Received new contract signed event from GoodLeap. applicationId: {}",
      contractSignedEvent.getApplicationId() != null ? contractSignedEvent.getApplicationId() : "null");*/
    String errorMsg = "";
    try {
      errorMsg = goodleapService.updateFinancialAgreementSigned(contractSignedEvent.getApplicationId(), contractSignedEvent.getTimestamp());
    } catch (Exception e) {
      errorMsg = e.getMessage();
    }
    if (errorMsg.isBlank()) {
      return ResponseEntity.ok("Financial Agreement Signed date successfully updated");
    }
    else {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + errorMsg);
    }
  }

  @Data
  public static class ContractSignedEvent {
    String event, applicationId, timestamp, referenceNumber;
  }
}
