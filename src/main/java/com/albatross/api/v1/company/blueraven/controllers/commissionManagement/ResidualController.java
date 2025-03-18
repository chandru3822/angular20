package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.*;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.ResidualService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/commissionManagement/residuals")
@RequiredArgsConstructor
public class ResidualController {

  private final ResidualService residualService;

  @GetMapping(value = "")
  public List<Residual> getResiduals() {
    return residualService.getResiduals();
  }

  @GetMapping(value = "/projects")
  public List<ResidualService.ResidualProject> getResidualProjects(@RequestParam String search) {
    return residualService.getResidualProjects(search);
  }

  @Data
  public static class ProjectOverride {
    Long projectId;
    String overrideDate;
  }

  @PostMapping(value = "/projectOverride")
  public void saveProjectOverride(@RequestBody ProjectOverride projectOverride) {
    residualService.saveProjectOverride(projectOverride);
  }


  @GetMapping(value = "/currentClawbacks/{userId}")
  public List<ResidualDetail> getCurrentClawbacks(@PathVariable Long userId) {
    return residualService.getCurrentClawbacks(userId);
  }

  @GetMapping(value = "/qualifiedLifetime/{userId}")
  public List<ResidualDetail> getResidualQualifiedLifetimeFds(@PathVariable Long userId) {
    return residualService.getResidualQualifiedLifetimeFds(userId);
  }

  @GetMapping(value = "/qualifiedPeriod/{userId}")
  public List<ResidualDetail> getResidualQualifiedFdsThisPeriod(@PathVariable Long userId) {
    return residualService.getResidualQualifiedFdsThisPeriod(userId);
  }

  @GetMapping(value = "/notQualifiedPeriod/{userId}")
  public List<ResidualDetail> getResidualNotQualifiedFdsThisPeriod(@PathVariable Long userId) {
    return residualService.getResidualNotQualifiedFdsThisPeriod(userId);
  }

  @GetMapping(value = "/{residualId}/snapshotFdc")
  public List<ResidualDetail> getSnapshotFdc(@PathVariable Long residualId,
                                             @RequestParam Long userId,
                                             @RequestParam Long snapshotTypeId) {
    return residualService.getSnapshotFdc(residualId, userId, snapshotTypeId);
  }

  @GetMapping(value = "/plans")
  public List<ResidualPlan> getResidualPlans() {
    return residualService.getResidualPlans();
  }

  @GetMapping(value = "/plan/{planId}")
  public String getResidualPlanDetails(@PathVariable Long planId) {
    return residualService.getResidualPlanDetails(planId);
  }

  @GetMapping(value = "/_search")
  public String findResidualPlanUsers(
    @RequestParam String query,
    @RequestParam(required = false) Long planId) {
    return residualService.findUserForResidual(query, planId);
  }

  @PostMapping(value = "/plan")
  public ResponseEntity<Object> updateResidualPlan(@RequestBody ResidualPlan residualPlan) {
    String detail = residualService.updateResidualPlan(residualPlan);
    return detail == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(detail);
  }

  @GetMapping(value = "/residualPlanUser/{userId}/history")
  public String getOldPlans(@PathVariable Long userId) {
    return residualService.getResidualPlanUserHistory(userId);
  }

  @PostMapping(value = "/{planId}/users")
  public ResponseEntity insertUser(@PathVariable Long planId,
                                   @RequestBody PlanAssignment user) {
    residualService.insertUser(planId, user);
    String users = residualService.getResidualPlanUsers(planId);
    return ResponseEntity.ok(users);
  }

  @DeleteMapping(value = "/plan/{id}")
  public void deletePlan(@PathVariable Long id) {
    residualService.deletePlan(id);
  }

  @PostMapping(value = "/plan/{id}/approve")
  public String approvePlan(@PathVariable Long id) {
    residualService.approvePlan(id);
    return getResidualPlanDetails(id);
  }

  @PostMapping(value = "/plan/{planId}/allocation")
  public String insertAllocation(@PathVariable Long planId,
                                 @RequestBody ResidualPlanAllocation rpa) {
    return residualService.insertAllocation(planId, rpa);
  }

  @DeleteMapping(value = "/plan/{planId}/allocation/{id}")
  public void removeAllocation(@PathVariable Long planId,
                               @PathVariable Long id) {
    residualService.removeAllocation(planId, id);
  }

  @PutMapping(value = "/plan/{planId}/allocation")
  public void updateAllocation(@PathVariable Long planId,
                               @RequestBody ResidualPlanAllocation rpa) {
    residualService.updateAllocation(planId, rpa);
  }

  @PostMapping(value = "/plan/{id}/clone")
  public ResponseEntity cloneResidualPlan(@PathVariable Long id,
                                          @RequestBody ResidualPlan residualPlan) {
    Optional<Long> clonePlan = residualService.clonePlan(id, residualPlan);
    if (clonePlan.isPresent()) {
      String residualPlanDetail = residualService.getResidualPlanDetails(clonePlan.get());
      return ResponseEntity.ok(residualPlanDetail);
    }
    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
  }

  @GetMapping(value = "/{id}/availableSources")
  public List<ResidualSource> getAvailableSources(@PathVariable Long id) {
    return residualService.getAvailableSources(id);
  }

  @PostMapping(value = "/{planId}/source")
  public ResidualSource saveSource(@PathVariable Long planId, @RequestBody ResidualSource source) {
    return residualService.saveSource(planId, source);
  }

  @PutMapping(value = "/{planId}/source")
  public ResidualSource updateSource(@PathVariable Long planId, @RequestBody ResidualSource source) {
    return residualService.updateSource(planId, source);
  }

  @DeleteMapping(value = "/{planId}/source/{sourceId}")
  public void removeSource(@PathVariable Long planId, @PathVariable Long sourceId) {
    residualService.removeSource(planId, sourceId);
  }
}

