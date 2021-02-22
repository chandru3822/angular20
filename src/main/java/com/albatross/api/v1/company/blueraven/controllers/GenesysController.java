package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.GenesysService;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.mypurecloud.sdk.v2.ApiException;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/genesys")
@Slf4j
public class GenesysController {
  @Autowired
  private GenesysService genesysService;

  @GetMapping(value = "/outboundCall/{phoneNumber}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<String> getContactUrlByPhone(@PathVariable String phoneNumber) {
    JSONObject contactJson = genesysService.getContactUrlByPhone(phoneNumber);
    if (contactJson != null) {
      return ResponseEntity.ok(contactJson.toString());
    }
    else {
      return ResponseEntity.badRequest().body("No contact found");
    }
  }

  @GetMapping(value = "/inboundCall/{phoneNumber}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity getContactDetailsByPhone(@PathVariable String phoneNumber) {
    try {
      JSONObject contactJson = genesysService.getContactDetailsByPhone(phoneNumber);
      if (contactJson != null) {
        return ResponseEntity.ok(contactJson.toString());
      }
      else {
        return ResponseEntity.badRequest().body("No contact found");
      }

    } catch (Exception e) {
      String msg = "GENE: Error getting contact by phone number";
      log.error(msg, e);
      return ResponseEntity.badRequest().body("Error getting contact by phone number");
    }
  }

  @PutMapping(value = "/inboundCall/{phoneNumber}/{agentId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity updateAgentId(@PathVariable String phoneNumber, @PathVariable String agentId) {
    try {
      JSONObject contactJson = new JSONObject();
      boolean success = genesysService.updateAgentId(phoneNumber, agentId);
      if (success) {
        contactJson.put("success", true);
        return ResponseEntity.ok(contactJson.toString());
      }
      else {
        return ResponseEntity.badRequest().body("Error updating contact Agent ID: No contact found for phone number");
      }
    } catch (Exception e) {
      String msg = "GENE: Error updating contacts";
      log.error(msg, e);
      return ResponseEntity.badRequest().body("Error updating contacts");
    }
  }

  @PostMapping(value = "/contact/{id}")
  public ResponseEntity addContact(@RequestBody List<CustomFieldValue> values, @PathVariable Long id) {
    try {
      genesysService.addContact(id, values);
      return ResponseEntity.ok("Contact successfully added.");
    } catch (ApiException e) {
      JSONObject apiException = new JSONObject(e.getRawBody());
      String msg = "GENE: Error adding contact: {}";
      log.error(msg, apiException.getString("message"));
      return ResponseEntity.badRequest().body("Error adding contact");
    }
    catch (IOException e) {
      String msg = "GENE: Error adding contact: {}";
      log.error(msg, e.getMessage());
      return ResponseEntity.badRequest().body("Error adding contact");
    }
  }

  @PutMapping(value = "/contact/{id}")
  public ResponseEntity updateContact(@RequestBody List<CustomFieldValue> values, @PathVariable Long id) {
    try {
      genesysService.updateContact(id);
      return ResponseEntity.ok("Contact successfully updated.");
    } catch (ApiException e) {
      JSONObject apiException = new JSONObject(e.getRawBody());
      String msg = "GENE: Error adding contact: {}";
      log.error(msg, apiException.getString("message"));
      return ResponseEntity.badRequest().body("Error adding contact");
    }
    catch (IOException e) {
      String msg = "GENE: Error adding contact: {}";
      log.error(msg, e.getMessage());
      return ResponseEntity.badRequest().body("Error adding contact");
    }
  }
}
