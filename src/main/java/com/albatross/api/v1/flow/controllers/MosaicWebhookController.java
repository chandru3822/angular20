package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.company.blueraven.services.MosaicService;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping(value = "/webhook/mosaic")
@RequiredArgsConstructor
public class MosaicWebhookController {

  private final MosaicService mosaicService;

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(value = "/contractSigned")
  public ResponseEntity updateContractSignedDate(@RequestBody ContractSignedEventWrapper contractSignedEventWrapper) {
    String msg;
    if (contractSignedEventWrapper.getData() == null) {
      msg = "MOSAIC: Data is missing";
      log.error(msg);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
    }

    String mosaicApplicationId = contractSignedEventWrapper.getData().getAttributes().getApplicationId();
    String eventTime = contractSignedEventWrapper.getData().getAttributes().getEventTime();
    /*log.debug(
        "GOODLEAP: Received new contract signed event from GoodLeap. applicationId: {}",
      contractSignedEvent.getApplicationId() != null ? contractSignedEvent.getApplicationId() : "null");*/
    String errorMsg = "";
    try {
      errorMsg = mosaicService.updateFinancialAgreementSigned(mosaicApplicationId, eventTime);
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
  @JsonIgnoreProperties(ignoreUnknown = true)
  public static class ContractSignedEventWrapper {
    private ContractSignedEvent data;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ContractSignedEvent {
      private String type;
      private String id;
      private Attributes attributes;

      @Data
      @JsonIgnoreProperties(ignoreUnknown = true)
      public static class Attributes {
        private String eventTime;
        private String applicationId;
        private String applicationLink;
        private String offerId;
        private String offerLink;
        private String contractLink;
      }
    }
  }
}
