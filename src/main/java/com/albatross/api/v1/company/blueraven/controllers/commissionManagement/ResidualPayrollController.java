package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.PayrollSearch;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.ResidualPayrollService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.Optional;

@Slf4j
@Hidden
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/payroll/residual")
@RequiredArgsConstructor
public class ResidualPayrollController {

  private final ResidualPayrollService residualPayrollService;

  @PostMapping(value = "/search")
  public String residualSearch(@RequestBody PayrollSearch searchQuery) {
    return residualPayrollService.residualSearch(searchQuery);
  }

  @GetMapping(value = "/current")
  public ResponseEntity<?> getCurrentResidual() {
    Long currentResidualId = residualPayrollService.findCurrentResidual();
    if (currentResidualId == null) {
      return ResponseEntity.notFound().build();
    }
    Optional<String> current = residualPayrollService.getResidualById(currentResidualId);
    if (current.isEmpty()) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(current.get());
  }

  @PostMapping(value = "/{residualId}")
  public ResponseEntity<?> updateResidualById(
      @PathVariable("residualId") Long residualId,
      @RequestBody ResidualPayrollService.PayrollUpdateRequest updateRequest)
      throws SQLException {
    boolean updated = residualPayrollService.updateResidual(residualId, updateRequest);
    if (!updated) {
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }

    return getResidual(residualId);
  }

  @GetMapping(value = "/{residualId}")
  public ResponseEntity<?> getResidual(@PathVariable Long residualId) {
    Optional<String> residualById = residualPayrollService.getResidualById(residualId);
    if (residualById.isEmpty()) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(residualById.get());
  }

  @PostMapping(value = "/{residualId}/submit")
  public void submitResidual(@PathVariable Long residualId) {
    residualPayrollService.submitToPay(residualId);
  }

  @PostMapping(value = "/{residualId}/approve")
  public void approveResidual(
      @PathVariable Long residualId, @RequestBody ResidualPayrollService.PayrollApproveRequest request) {
    residualPayrollService.approveResidual(residualId, request);
  }

  @PostMapping(value = "/{residualId}/reject")
  public void rejectResidual(@PathVariable Long residualId) {
    residualPayrollService.rejectResidual(residualId);
  }

  @GetMapping(value = "/{residualId}/adjustments")
  public String getResidualAdjustments(@PathVariable Long residualId, @RequestParam Long projectId) {
    return residualPayrollService.getResidualAdjustments(residualId, projectId);
  }

  @PostMapping(value = "/{residualId}/adjustments")
  public void addResidualAdjustment(
      @PathVariable Long residualId,
      @RequestBody ResidualPayrollService.PayrollAdjustmentRequest adjustmentRequest) {
    residualPayrollService.addResidualAdjustment(residualId, adjustmentRequest);
  }

  @GetMapping(value = "/{residualId}/snapshot")
  public String getResidualSnapshot(@PathVariable Long residualId) {
    return residualPayrollService.getResidualSearchDetail(residualId);
  }

}
