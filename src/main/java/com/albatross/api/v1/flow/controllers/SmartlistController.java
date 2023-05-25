package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smartlist.*;
import com.albatross.api.v1.flow.services.report.SmartlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@PreAuthorize("hasFeatureAccess('SMARTLIST')")
@RequestMapping(value = "/api/v1/flow/smartlist")
public class SmartlistController {

  private final SmartlistService smartlistService;

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_VIEW', 'SMARTLIST_ADMIN')")
  @GetMapping(value = "/{smartlistId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> getSmartlistById(@PathVariable Long smartlistId, @RequestParam(required = false) boolean includeAccessControl) {
    return new ResponseEntity<>(smartlistService.getById(smartlistId, includeAccessControl), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_ADD', 'SMARTLIST_ADMIN')")
  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> addSmartlist(@RequestBody Smartlist smartlist) {
    return new ResponseEntity<>(smartlistService.addSmartlist(smartlist), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_EDIT', 'SMARTLIST_ADMIN')")
  @PutMapping(value = "/{smartlistId}", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateSmartlist(@RequestBody ReportDTO report) {
    smartlistService.updateSmartlist(report.getSmartlist(), report.getFields(), report.getRequirements());
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_DELETE', 'SMARTLIST_ADMIN')")
  @DeleteMapping(value = "/{smartlistId}")
  public ResponseEntity<Void> deleteSmartlist(@PathVariable Long smartlistId) {
    smartlistService.delete(smartlistId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/mine", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getMySmartlists() {
    return new ResponseEntity<>(smartlistService.getMine(), HttpStatus.OK);
  }

  @GetMapping(value = "/shared", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getSharedSmartlists() {
    return new ResponseEntity<>(smartlistService.getShared(), HttpStatus.OK);
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

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_ADD')")
  @PostMapping(value = "/{smartlistId}/copy")
  public ResponseEntity<Smartlist> copySmartlist(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.copy(smartlistId), HttpStatus.OK);
  }

  @GetMapping(value = "/sharables", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistAccessControl>> getSharableEntities() {
    return new ResponseEntity<>(smartlistService.getSharableEntities(), HttpStatus.OK);
  }

  @GetMapping(value = "/access", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistAccessControl>> getSmartlistAvailableAccess() {
    return new ResponseEntity<>(smartlistService.getAvailableAccess(), HttpStatus.OK);
  }

  @GetMapping(value = "/{smartlistId}/access", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistAccessControl>> getSmartlistAccess(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getAccessById(smartlistId), HttpStatus.OK);
  }

  @Transactional
  @PostMapping(value = "/{smartlistId}/access")
  public ResponseEntity<Void> updateSmartlistAccess(@PathVariable Long smartlistId, @RequestBody SmartlistAccessDTO smartlistAccess) {
    if (smartlistAccess.getNewAccess() != null) {
      smartlistService.addAccess(smartlistId, smartlistAccess.getNewAccess());
    }

    if (smartlistAccess.isUpdatePublic()) {
      smartlistService.updatePublicStatus(smartlistId, smartlistAccess.isPublic());
    }

    if (smartlistAccess.getUpdatedAccess() != null && !smartlistAccess.getUpdatedAccess().isEmpty()) {
      smartlistService.updateAccess(smartlistId, smartlistAccess.getUpdatedAccess());
    }

    if (smartlistAccess.getDeletedAccess() != null && !smartlistAccess.getDeletedAccess().isEmpty()) {
      smartlistService.deleteAccess(smartlistId, smartlistAccess.getDeletedAccess());
    }

    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/{smartlistId}/requirement", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistRequirement>> getSmartlistRequirements(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getRequirements(smartlistId, true), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_EDIT', 'SMARTLIST_ADMIN')")
  @PostMapping(value = "/{smartlistId}/requirement", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistRequirement> addSmartlistRequirement(@PathVariable Long smartlistId, @RequestBody SmartlistRequirement requirement) {
    return new ResponseEntity<>(smartlistService.addRequirement(smartlistId, requirement), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_EDIT', 'SMARTLIST_ADMIN')")
  @PutMapping(value = "/{smartlistId}/requirement/{requirementId}", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<SmartlistRequirement> updateRequirementOfSmartlist(@RequestBody SmartlistRequirement requirement) {
    return new ResponseEntity<>(smartlistService.updateRequirement(requirement), HttpStatus.OK);
  }

  @GetMapping(value = "/{smartlistId}/field", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistFieldAssignment>> getAssignedFields(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getFields(smartlistId), HttpStatus.OK);
  }

//  @DeleteMapping(value = "{smartlistId}/access/{smartlistAccessControlId}")
//  public ResponseEntity<Void> deleteSmartlistAccess(@PathVariable Long smartlistId, @PathVariable Long smartlistAccessControlId) {
//    smartlistService.deleteAccess(smartlistId, smartlistAccessControlId);
//    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
//  }

  @PutMapping(value = "/{smartlistId}/owner")
  public ResponseEntity<Void> updateSmartlistOwner(@PathVariable Long smartlistId, @RequestBody SmartlistAccessControl newOwner) {
    smartlistService.updateOwner(smartlistId, newOwner);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_EDIT', 'SMARTLIST_ADMIN')")
  @PutMapping(value = "/{smartlistId}/toggleProjectDetails")
  public ResponseEntity<Void> updateSmartlistType(@PathVariable Long smartlistId) {
    smartlistService.updateProjectDetails(smartlistId);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_EDIT', 'SMARTLIST_ADMIN')")
  @PutMapping(value = "/{smartlistId}/toggleObjectType", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> updateSmartlistObjectType(@RequestBody Smartlist smartlist) {
    return new ResponseEntity<>(smartlistService.updateObjectType(smartlist), HttpStatus.OK);
  }

  @PreAuthorize("hasFeatureAccessLevel('SMARTLIST_ADMIN')")
  @GetMapping(value = "/{smartlistId}/metrics", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistMetric>> getSmartlistMetrics(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getMetrics(smartlistId), HttpStatus.OK);
  }


  @GetMapping(value = "/fields", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SmartlistFieldAssignment>> getAvailableFields(@RequestParam List<Long> objectTypeIds, @RequestParam boolean projectDetails) {
    return new ResponseEntity<>(smartlistService.getAvailableFields(objectTypeIds, projectDetails), HttpStatus.OK);
  }

  @PostMapping(value = "/adhoc", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Map<String, Object>>> getAdhocReportData(@RequestBody ReportDTO report, @RequestParam Integer limit, @RequestParam(required = false) String timezone) {
    return ResponseEntity.ok(smartlistService.getAdhocReportData(report.getSmartlist(), report.getFields(), report.getRequirements(), limit, timezone));
  }

  @PreAuthorize("hasRootLevelAccess()")
  @PostMapping(value = "/adhoc/query", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Map<String, Object>> getReportQuery(@RequestBody ReportDTO report) {
    var result = smartlistService.getAdhocReportData(report.getSmartlist(), report.getFields(), report.getRequirements(), null, null, true);
    return ResponseEntity.ok(result.get(0));
  }
}
