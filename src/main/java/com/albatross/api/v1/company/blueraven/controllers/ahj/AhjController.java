package com.albatross.api.v1.company.blueraven.controllers.ahj;

import com.albatross.api.v1.company.blueraven.models.ahj.AhjRequirement;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjSummary;
import com.albatross.api.v1.company.blueraven.services.ahj.AhjRequirementService;
import com.albatross.api.v1.company.blueraven.services.ahj.AhjService;
import com.albatross.api.v1.company.blueraven.services.ahj.AhjUtilityService;
import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/ahj")
public class AhjController {
  @Autowired private AhjService ahjService;

  @Autowired private AhjRequirementService ahjRequirementService;

  @Autowired private AhjUtilityService ahjUtilityService;

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
    return ahjService.saveAhj(null, ahjSummary);
  }

  @PutMapping(value = "/{id}")
  public Optional<AhjSummary> updateAhj(@PathVariable Long id, @RequestBody AhjSummary ahj) {
    return ahjService.saveAhj(id, ahj);
  }

  @DeleteMapping(value = "/{id}")
  public void deleteAhj(@PathVariable Long id) {
    ahjService.deleteAhj(id);
  }

  @PostMapping(value = "/{ahjId}/{itemType}/requirement")
  public AhjRequirement addRequirement(
      @PathVariable Long ahjId,
      @PathVariable String itemType,
      @RequestBody AhjRequirement requirement) {
    if (itemType.equals("utility")) {
      return ahjUtilityService.addRequirement(ahjId, requirement).orElse(null);
    }

    return ahjRequirementService.addRequirement(ahjId, requirement).orElse(null);
  }

  @PutMapping(value = "/{ahjId}/{itemType}/requirement/{requirementId}")
  public AhjRequirement updateRequirement(
      @PathVariable Long ahjId,
      @PathVariable String itemType,
      @PathVariable Long requirementId,
      @RequestBody AhjRequirement requirement) {
    if (itemType.equals("utility")) {
      return ahjUtilityService.updateRequirement(ahjId, requirementId, requirement).orElse(null);
    }
    return ahjRequirementService.updateRequirement(ahjId, requirementId, requirement).orElse(null);
  }

  @PutMapping(value = "/{itemType}/requirement/{originalRequirementId}/archive")
  public void archiveRequirement(
      @PathVariable String itemType, @PathVariable Long originalRequirementId) {
    if (itemType.equals("utility")) {
      ahjUtilityService.archiveRequirement(originalRequirementId);
    }
    ahjRequirementService.archiveRequirement(originalRequirementId);
  }
}
