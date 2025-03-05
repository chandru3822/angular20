package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.company.blueraven.services.AwsService;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping(value = "/webhook/aws")
@RequiredArgsConstructor
public class AwsWebhookController {

  private static final Integer UTILITY_BILL_RESULTS_EVENT = 100;
  @Value("${aws.token}")
  private String SECRET_TOKEN;
  private final AwsService awsService;

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(value = "/event")
  public void handleEvent(
          @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
          @RequestBody AwsEventWrapper eventWrapper) {
    if (authorizationHeader == null || !isValidToken(authorizationHeader)) {
      log.error("Unauthorized request: Missing or invalid token");
      return;
    }

    if (eventWrapper.getEventType() == null) {
      log.error("AWS: Event type is missing");
      return;
    }

    if (eventWrapper.getEventType().equals(UTILITY_BILL_RESULTS_EVENT)) {
      if (eventWrapper.getJobId() == null) {
        log.error("AWS: Job ID is missing");
        return;
      }
      try {
        awsService.processUtilityBillResults(eventWrapper.getJobId(), eventWrapper.getText());
        log.info("Successfully updated customer from document {} with info: {}", eventWrapper.getJobId(), eventWrapper.getText());
      } catch (Exception e) {
          log.error("AWS Utility Bill Error: {}", e.getMessage());
        return;
      }
    } else {
      log.error("Unsupported event type: {}", eventWrapper.getEventType());
      return;
    }
  }

  private boolean isValidToken(String authorizationHeader) {
    if (!authorizationHeader.startsWith("Bearer ")) {
      return false;
    }
    String token = authorizationHeader.substring(7);
    return SECRET_TOKEN.equals(token);
  }

  @Data
  public static class AwsEventWrapper {
    String jobId;
    Integer eventType;
    UtilityBillResult text;
  }

  @Data
  public static class UtilityBillResult {
    @JsonProperty("Premise Number")
    TextractResult premiseNumber;
    @JsonProperty("Customer Name")
    TextractResult customerName;
    @JsonProperty("Meter Number")
    TextractResult meterNumber;
    @JsonProperty("Account Number")
    TextractResult accountNumber;
    @JsonProperty("Service Address")
    TextractResult serviceAddress;
  }

  @Data
  public static class TextractResult {
    String text;
    Double confidence;
  }
}
