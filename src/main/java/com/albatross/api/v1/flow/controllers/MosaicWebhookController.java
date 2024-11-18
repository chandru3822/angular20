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

  private final String CONTRACT_SIGNED_EVENT = "event.offer.ContractSigned";

  private final String CONTRACT_COUNTER_SIGNED_EVENT = "event.offer.ContractCountersigned";

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(value = "/webhook/offer")
  public ResponseEntity handleOffer(@RequestBody EventWrapper eventWrapper) {
    String errorMsg = "";
    String msg = "";
    if (eventWrapper.getData() == null) {
      errorMsg = "MOSAIC: Data is missing";
      log.error(errorMsg);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
    }

    String eventType = eventWrapper.getData().getType();
    if (eventType.equals(CONTRACT_SIGNED_EVENT)) {
      String mosaicApplicationId = eventWrapper.getData().getAttributes().getApplicationId();
      String eventTime = eventWrapper.getData().getAttributes().getEventTime();
      try {
        errorMsg = mosaicService.updateFinancialAgreementSigned(mosaicApplicationId, eventTime);
      } catch (Exception e) {
        errorMsg = e.getMessage();
      }
      msg = "Financial Agreement Signed date successfully updated";
    }
    else if (eventType.equals(CONTRACT_COUNTER_SIGNED_EVENT)) {
      String mosaicApplicationId = eventWrapper.getData().getAttributes().getApplicationId();
      String eventTime = eventWrapper.getData().getAttributes().getEventTime();
      try {
        errorMsg = mosaicService.updateCountersigned(mosaicApplicationId, eventTime);
      } catch (Exception e) {
        errorMsg = e.getMessage();
      }
      msg = "Countersign date successfully updated";
    }
    else {
      return ResponseEntity.ok("Unsupported event type: " + eventType);
    }

    if (errorMsg.isBlank()) {
      return ResponseEntity.ok(msg);
    }
    else {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + errorMsg);
    }
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  public static class EventWrapper {
    private Event data;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Event {
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
