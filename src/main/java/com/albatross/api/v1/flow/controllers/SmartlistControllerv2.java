package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smartlistv2.Smartlistv2;
import com.albatross.api.v1.flow.services.SmartlistServicev2;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequiredArgsConstructor
@PreAuthorize("hasFeatureAccess('SMARTLIST')")
@RequestMapping(value = "/api/v1/flow/smartlistv2")
public class SmartlistControllerv2 {

  private final SmartlistServicev2 smartlistServicev2;

  @GetMapping(value = "/mine", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlistv2>> getMySmartlists() {
    return new ResponseEntity<>(smartlistServicev2.getMine(), HttpStatus.OK);
  }

  @GetMapping(value = "/public", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlistv2>> getPublicSmartlists() {
    return new ResponseEntity<>(smartlistServicev2.getPublic(), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_ADMIN')")
  @GetMapping(value = "/all", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlistv2>> getAllSmartlists() {
    return new ResponseEntity<>(smartlistServicev2.getAll(), HttpStatus.OK);
  }

  @GetMapping(value = "/{smartlistId}/export", produces = "text/csv")
  public ResponseEntity<String> exportSmartlist(@PathVariable Long smartlistId, @RequestParam(required = false) String timezone) {
    try {
      return new ResponseEntity<>(smartlistServicev2.export(smartlistId, timezone), HttpStatus.OK);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unable to export smartlist", e);
    }
  }

  @PostMapping(value = "/{smartlistId}/copy")
  public ResponseEntity<Smartlistv2> copySmartlist(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistServicev2.copy(smartlistId), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_DELETE', 'SMARTLIST_ADMIN')")
  @DeleteMapping(value = "/{smartlistId}")
  public ResponseEntity<Void> deleteSmartlist(@PathVariable Long smartlistId) {
    smartlistServicev2.delete(smartlistId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }
}
