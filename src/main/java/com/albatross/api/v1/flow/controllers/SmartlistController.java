package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.CustomFieldService;
import com.albatross.api.v1.flow.services.ObjectTypeService;
import com.albatross.api.v1.flow.services.SmartlistService;
import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Objects;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/smartlist")
public class SmartlistController {


  private final SmartlistService smartlistService;

  private final CustomFieldService customFieldService;
  private final ObjectTypeService objectTypeService;

  private final SecurityService securityService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getSmartlists() {
    User user = securityService.getCurrentUser();
    if (!securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("VIEW_ALL", "VIEW", "ADMIN"))) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    return new ResponseEntity<>(smartlistService.getSmartlists(), HttpStatus.OK);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> addSmartlist(@RequestBody Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    if (!securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("ADD", "ADMIN"))) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    return new ResponseEntity<>(smartlistService.addSmartlist(smartlist), HttpStatus.OK);
  }

  //humes dont hate, i added an endpoint so i could get the sql string on the frontend.
  //this has helped me a ton with work queues especially when the say it is only failing in prod
  @GetMapping(value = "/{smartlistId}/getSqlString", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getSqlString (@PathVariable Long smartlistId) {
    return smartlistService.getSmartlistSqlString(smartlistId);
  }

  @GetMapping(value = "/{smartlistId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> getSmartlist(@PathVariable Long smartlistId) {
    User user = securityService.getCurrentUser();
    if (!securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("VIEW", "VIEW_ALL", "ADMIN"))) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    return new ResponseEntity<>(smartlistService.getSmartlist(smartlistId), HttpStatus.OK);
  }

  @PutMapping(value = "/{smartlistId}", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateSmartlist(@RequestBody Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    if (!securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("EDIT", "ADMIN"))) {
      return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
    smartlistService.updateSmartlist(smartlist);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @DeleteMapping(value = "/{smartlistId}")
  public ResponseEntity<Void> deleteSmartlist(@PathVariable Long smartlistId) {
    User user = securityService.getCurrentUser();

    if (!securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("DELETE", "ADMIN"))) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    smartlistService.deleteSmartlist(smartlistId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/{smartlistId}/field", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistFieldAssignment>> getAssignedFieldSmartlistFields(@PathVariable Long smartlistId) {

    Smartlist smartlist = smartlistService.getSmartlist(smartlistId);

    if (!Objects.equals(smartlistId, smartlist.getId())) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }

    List<SmartlistFieldAssignment> fields;

    if (smartlist.isProjectDetails()) {
      fields = smartlistService.getAssignedProjectDetailsFields(smartlistId);
    } else {
      fields = smartlistService.getAssignedFields(smartlistId);
    }

    return new ResponseEntity<>(fields, HttpStatus.OK);
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
    return new ResponseEntity<>(smartlistService.getRequirements(smartlistId, true), HttpStatus.OK);
  }

  @PostMapping(value = "/{smartlistId}/requirement", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistRequirement> addRequirementToSmartlist(@PathVariable Long smartlistId, @RequestBody SmartlistRequirement requirement) {
    return new ResponseEntity<>(smartlistService.addRequirement(smartlistId, requirement), HttpStatus.OK);
  }

  @PutMapping(value = "/{smartlistId}/requirement/{requirementId}", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistRequirement> updateRequirementOfSmartlist(@PathVariable Long smartlistId, @PathVariable Long requirementId, @RequestBody SmartlistRequirement requirement) {
    return new ResponseEntity<>(smartlistService.updateRequirement(requirement), HttpStatus.OK);
  }

  @DeleteMapping(value = "/{smartlistId}/requirement/{requirementId}")
  public ResponseEntity<Void> deleteRequirementFromSmartlist(@PathVariable Long requirementId) {
    smartlistService.deleteRequirement(requirementId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/{smartlistId}/logic", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistLogic>> getLogicBySmartlistId(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getLogic(smartlistId), HttpStatus.OK);
  }

  @PutMapping(value = "/{smartlistId}/logic", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistLogic>> updateLogicBySmartlistId(@PathVariable Long smartlistId, @RequestBody List<SmartlistLogic> logic) {
    return new ResponseEntity<>(smartlistService.updateLogic(smartlistId, logic), HttpStatus.OK);
  }

  @GetMapping(value = "/{smartlistId}/csv", produces = "text/csv")
  public ResponseEntity<String> getSmartlistCsvById(@PathVariable Long smartlistId,
                                                    @RequestParam(required = false) String timezone) throws JsonProcessingException {
    try {
        return new ResponseEntity<>(smartlistService.getCsv(smartlistId, timezone), HttpStatus.OK);
    } catch (RuntimeException e) {
        throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unable to generate CSV file", e);
    }
  }

  @GetMapping(value = "/{smartlistId}/data", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistResult> getSmartlistDataById(@PathVariable Long smartlistId) {
      try {
          return new ResponseEntity<>(smartlistService.getSmartlistResults(smartlistId), HttpStatus.OK);
      } catch (RuntimeException e) {
          throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unable to generate results", e);
      }
  }

  @GetMapping(value = "/companyObjectTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CompanyObjectType>> getCompanyObjectTypes() {
      List<CompanyObjectType> types = objectTypeService.getCompanyObjectTypes();
      return new ResponseEntity<>(types, HttpStatus.OK);
  }

  @GetMapping(value = "/availableFieldsByType", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistFieldAssignment>> getAvailableSmartlistFieldsByObjectType(@RequestParam Long objectTypeId) {
    return new ResponseEntity<>(smartlistService.getAvailableFields(objectTypeId), HttpStatus.OK);
  }

  @GetMapping(value = "/availableFieldByCfgaId/{cfgaId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistFieldAssignment> getAvailableSmarlistFieldByCfgaId(@PathVariable Long cfgaId) {
      return new ResponseEntity<>(smartlistService.getAvailableFieldByCfgaId(cfgaId), HttpStatus.OK);
  }

  @GetMapping(value = "/availableProjectDetailsFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistFieldAssignment>> getAvailableProjectDetailsFields() {
    return new ResponseEntity<>(smartlistService.getAvailableProjectDetailsFields(), HttpStatus.OK);
  }

  @GetMapping(value = "/shared", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getPublicSmartlistsByType(@RequestParam Long objectTypeId) {
    User user = securityService.getCurrentUser();
    if (!securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("VIEW", "VIEW_ALL", "ADMIN"))) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    return new ResponseEntity<>(smartlistService.getSharedByType(objectTypeId), HttpStatus.OK);
  }

  @PutMapping(value = "/{smartlistId}/toggleProjectDetails")
  public ResponseEntity<Void> updateSmartlistType(@PathVariable Long smartlistId) {
    User user = securityService.getCurrentUser();
    if (!securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("EDIT", "ADMIN"))) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    smartlistService.toggleProjectDetails(smartlistId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @PutMapping(value = "/{smartlistId}/toggleObjectType", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> updateSmartlistObjectType(@RequestBody Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    if (!securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("EDIT", "ADMIN"))) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    return new ResponseEntity<>(smartlistService.updateObjectType(smartlist), HttpStatus.OK);
  }

  @PostMapping(value = "/{smartlistId}/copy")
  public ResponseEntity<Smartlist> copySmartlist(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.copy((smartlistId)), HttpStatus.OK);
  }
}
