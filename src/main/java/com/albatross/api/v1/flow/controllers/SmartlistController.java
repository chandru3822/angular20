package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Smartlist;
import com.albatross.api.v1.flow.model.SmartlistFieldAssignment;
import com.albatross.api.v1.flow.model.SmartlistRequirement;
import com.albatross.api.v1.flow.services.SmartlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/smartlist")
public class SmartlistController {

  private final SmartlistService smartlistService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getSmartlists() {
    return new ResponseEntity<>(smartlistService.getSmartlists(), HttpStatus.OK);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> addSmartlist(@RequestBody Smartlist smartlist) {
    return new ResponseEntity<>(smartlistService.addSmartlist(smartlist), HttpStatus.OK);
  }

  @GetMapping(value = "/{smartlistId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> getSmartlist(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getSmartlist(smartlistId), HttpStatus.OK);
  }

  @PutMapping(value = "/{smartlistId}", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateSmartlist(@RequestBody Smartlist smartlist) {
    smartlistService.updateSmartlist(smartlist);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/{smartlistId}/field", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistFieldAssignment>> getAssignedFieldSmartlistFields(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getAssignedFields(smartlistId), HttpStatus.OK);
  }

  @PostMapping(value = "/{smartlistId}/field", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistFieldAssignment> addFieldToSmartlist(@RequestBody SmartlistFieldAssignment assignment) {
    return new ResponseEntity<>(smartlistService.addField(assignment), HttpStatus.OK);
  }

  @DeleteMapping(value = "/{smartlistId}/field/{fieldId}")
  public ResponseEntity<Void> deleteFieldFromSmartlist(@PathVariable Long fieldId) {
    smartlistService.deleteFieldAssignment(fieldId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  // @TODO: Potentially should be in SmartlistFieldController?
  @PutMapping(value = "/{smartlistId}/order", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateSmartlistFieldOrder(@RequestBody List<SmartlistFieldAssignment> fields) {
    smartlistService.updateDisplayOrder(fields);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/{smartlistId}/requirement", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistRequirement>> getRequirementsBySmartlistId(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getRequirements(smartlistId), HttpStatus.OK);
  }

  @PostMapping(value = "/{smartlistId}/requirement", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistRequirement> addRequirementToSmartlist(@PathVariable Long smartlistId, @RequestBody SmartlistRequirement requirement) {
    return new ResponseEntity<>(smartlistService.addRequirement(smartlistId, requirement), HttpStatus.OK);
  }

  @DeleteMapping(value = "/{smartlistId}/requirement/{requirementId}")
  public ResponseEntity<Void> deleteRequirementFromSmartlist(@PathVariable Long requirementId) {
    smartlistService.deleteRequirement(requirementId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/availableFieldsByType", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistFieldAssignment>> getAvailableSmartlistFieldsByObjectType(@RequestParam Long objectTypeId) {
    return new ResponseEntity<>(smartlistService.getAvailableFields(objectTypeId), HttpStatus.OK);
  }
}
