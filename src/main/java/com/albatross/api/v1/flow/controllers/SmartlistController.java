package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smartlist.Smartlist;
import com.albatross.api.v1.flow.model.smartlist.SmartlistSharable;
import com.albatross.api.v1.flow.services.SmartlistService;
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
@RequestMapping(value = "/api/v1/flow/smartlist")
public class SmartlistController {

  private final SmartlistService smartlistService;

  @GetMapping(value = "/mine", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getMySmartlists() {
    return new ResponseEntity<>(smartlistService.getMine(), HttpStatus.OK);
  }

  @GetMapping(value = "/public", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getPublicSmartlists() {
    return new ResponseEntity<>(smartlistService.getPublic(), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_ADMIN')")
  @GetMapping(value = "/all", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getAllSmartlists() {
    return new ResponseEntity<>(smartlistService.getAll(), HttpStatus.OK);
  }

  @GetMapping(value = "/{smartlistId}/export", produces = "text/csv")
  public ResponseEntity<String> exportSmartlist(@PathVariable Long smartlistId, @RequestParam(required = false) String timezone) {
    try {
      return new ResponseEntity<>(smartlistService.export(smartlistId, timezone), HttpStatus.OK);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unable to export smartlist", e);
    }
  }

  @PostMapping(value = "/{smartlistId}/copy")
  public ResponseEntity<Smartlist> copySmartlist(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.copy(smartlistId), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_DELETE', 'SMARTLIST_ADMIN')")
  @DeleteMapping(value = "/{smartlistId}")
  public ResponseEntity<Void> deleteSmartlist(@PathVariable Long smartlistId) {
    smartlistService.delete(smartlistId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/sharables", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistSharable>> getSharableEntities() {
    return new ResponseEntity<>(smartlistService.getSharableEntities(), HttpStatus.OK);
  }

  @PostMapping(value = "/{smartlistId}/share", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistSharable> addSmartlistShare(@RequestBody SmartlistSharable share) {
    return new ResponseEntity<>(smartlistService.addShare(share), HttpStatus.OK);
  }
}
