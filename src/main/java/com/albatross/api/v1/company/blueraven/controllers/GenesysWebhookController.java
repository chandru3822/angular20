package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.GenesysService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping(value = "/webhook/genesys")
@RequiredArgsConstructor
public class GenesysWebhookController {

  private final GenesysService genesysService;

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(value = "/contactLeadStatus")
  public ResponseEntity updateContactLeadStatus(@RequestBody GenesysCallOutcome genesysCallOutcome)
      throws Exception {

    if (genesysService.updateLeadStatus(genesysCallOutcome.getContactId(), genesysCallOutcome.getCallOutcome())) {
      return ResponseEntity.ok("Contact successfully updated.");
    }
    else {
      return ResponseEntity.badRequest().body("Invalid Contact ID or Lead Status");
    }
  }

  @Data
  public static class GenesysCallOutcome {
    private Long contactId;
    private String callOutcome;
  }
}
