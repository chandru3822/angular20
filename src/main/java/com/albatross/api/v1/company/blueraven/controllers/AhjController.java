package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.ahj.AhjRequirement;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjSummary;
import com.albatross.api.v1.company.blueraven.services.AhjRequirementService;
import com.albatross.api.v1.company.blueraven.services.AhjService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/ahj")
public class AhjController {
  @Autowired
  private AhjService ahjService;

  @Autowired
  private AhjRequirementService ahjRequirementService;

  @GetMapping(value = "")
  public List<AhjSummary> getAhjList() {
    return ahjService.getAhjList();
  }

  @GetMapping(value = "/{id}")
  public Optional<AhjSummary> getAhjById(@PathVariable Long id) {
    return ahjService.getAhjById(id);
  }

  @PostMapping(value = "")
  public Optional<AhjSummary> createAhj(@RequestBody AhjSummary ahjSummary) {
    return ahjService.createAhj(ahjSummary);
  }

  @PutMapping(value = "/{id}")
  public Optional<AhjSummary> updateAhj(@PathVariable Long id, @RequestBody AhjSummary ahj) {
    return ahjService.saveAhj(id, ahj);
  }

  @DeleteMapping(value = "/{id}")
  public void deleteAhj(@PathVariable Long id) {
    ahjService.deleteAhj(id);
  }

  // REQUIREMENTS
  @GetMapping(value = "/{ahjId}/requirement/{originalRequirementId}/history")
  public List<AhjRequirement> getRequirementHistory(@PathVariable Long ahjId,
                                                    @PathVariable Long originalRequirementId) {
    return ahjRequirementService.getRequirementHistory(ahjId, originalRequirementId);
  }

  @PostMapping(value = "/{ahjId}/{itemType}/requirement")
  public AhjRequirement createRequirement(@PathVariable Long ahjId,
                                          @PathVariable String itemType,
                                          @RequestBody AhjRequirement requirement) {
    if (itemType.equals("utility")) {
//      return ahjUtilityService.addRequirement(ahjId, requirement);
      return null; // TODO: Remove this later when the Ahj Utility stuff is set up
    } else {
      return ahjRequirementService.addRequirement(ahjId, requirement);
    }
  }

  @PutMapping(value = "/{ahjId}/{itemType}/requirement/{requirementId}")
  public AhjRequirement updateRequirement(@PathVariable Long ahjId,
                                          @PathVariable String itemType,
                                          @PathVariable Long requirementId,
                                          @RequestBody AhjRequirement requirement) {
    if (itemType.equals("utility")) {
//      return ahjUtilityService.updateRequirement(ahjId, requirement, requirementId);
      return null; // TODO: Remove this later when the Ahj Utility stuff is set up
    } else {
      return ahjRequirementService.updateRequirement(ahjId, requirementId, requirement);
    }
  }

  @PutMapping(value = "/{itemType}/requirement/{originalRequirementId}/archive")
  public void archiveRequirement(@PathVariable String itemType,
                                 @PathVariable Long originalRequirementId) {
    if (itemType.equals("utility")) {
//      ahjUtilityService.archiveRequirement(requirement);
    } else {
      ahjRequirementService.archiveRequirement(originalRequirementId);
    }
  }
}
