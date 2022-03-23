package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.PayrollSearch;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.PayrollService;
import com.albatross.api.v1.flow.model.OverrideResult;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

@Slf4j
@Hidden
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/payroll")
@RequiredArgsConstructor
public class PayrollController {

  private final PayrollService payrollService;

  @GetMapping(value = "/current/{positionId}")
  public ResponseEntity<?> getCurrentPayroll(@PathVariable Long positionId) {
    Long currentPayrollId = payrollService.findCurrentPayroll(positionId);
    if (currentPayrollId == null) {
      return ResponseEntity.notFound().build();
    }
    Optional<String> current = payrollService.getPayrollById(currentPayrollId);
    if (current.isEmpty()) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(current.get());
  }

  @PostMapping(value = "/search")
  public String payrollSearch(@RequestBody PayrollSearch searchQuery) {
    return payrollService.payrollSearch(searchQuery);
  }

  @PostMapping(value = "/{payrollId}")
  public ResponseEntity<?> updatePayrollById(
      @PathVariable("payrollId") Long payrollId,
      @RequestBody PayrollService.PayrollUpdateRequest updateRequest)
      throws SQLException {
    boolean updated = payrollService.updatePayroll(payrollId, updateRequest);
    if (!updated) {
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }

    return getPayroll(payrollId);
  }

  @GetMapping(value = "/{payrollId}")
  public ResponseEntity<?> getPayroll(@PathVariable Long payrollId) {
    Optional<String> payrollById = payrollService.getPayrollById(payrollId);
    if (payrollById.isEmpty()) {
      return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(payrollById.get());
  }

  @PostMapping(value = "/{payrollId}/submit")
  public void submitPayroll(@PathVariable Long payrollId) {
    payrollService.submitToPay(payrollId);
  }

  @PostMapping(value = "/{payrollId}/approve")
  public void approvePayroll(
      @PathVariable Long payrollId, @RequestBody PayrollService.PayrollApproveRequest request) {
    payrollService.approvePayroll(payrollId, request);
  }

  @PostMapping(value = "/{payrollId}/reject")
  public void rejectPayroll(@PathVariable Long payrollId) {
    payrollService.rejectPayroll(payrollId);
  }

  @GetMapping(value = "/{payrollId}/snapshot/{positionId}")
  public String getPayrollSnapshot(@PathVariable Long payrollId, @PathVariable Long positionId) {
    return payrollService.getPayrollSearchDetail(payrollId, positionId);
  }

  @GetMapping(value = "/{payrollId}/adjustments")
  public String getPayrollAdjustments(@PathVariable Long payrollId, @RequestParam Long projectId) {
    return payrollService.getPayrollAdjustments(payrollId, projectId);
  }

  @PostMapping(value = "/{payrollId}/adjustments")
  public void addPayrollAdjustment(
      @PathVariable Long payrollId,
      @RequestBody PayrollService.PayrollAdjustmentRequest adjustmentRequest) {
    payrollService.addPayrollAdjustment(payrollId, adjustmentRequest);
  }

  @GetMapping(value = "/summary/prepare")
  public void preparePayrollSummary() {
    payrollService.preparePayrollSummary();
  }

  @GetMapping(value = "/summary/status")
  public String checkSummaryPreparationStatus() {
    String status = payrollService.checkSummaryPreparationStatus();
    JSONObject response = new JSONObject("{\"response\": " + status + "}");
    return response.toString();
  }

  @GetMapping(value = "/current/summary/{positionId}")
  public ResponseEntity<String> getCurrentPayrollSummary(@PathVariable Long positionId) {
    try {
      String summary = payrollService.getAccountSummaryForCurrentPayroll(positionId);
      return ResponseEntity.ok(summary);
    } catch (Exception e) {
      log.error("COMMISSION: payroll account summary error", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  @GetMapping(value = "/{payrollId}/summary")
  public ResponseEntity<String> getPayrollSummary(@PathVariable Long payrollId) {
    try {
      String summary = payrollService.getAccountSummaryByPayrollId(payrollId);
      return ResponseEntity.ok(summary);
    } catch (Exception e) {
      log.error("COMMISSION: payroll summary by payroll id error", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  @RequestMapping(value = "/{payrollId}/overrides", method = RequestMethod.GET)
  public List<OverrideResult> getAllOverrideDetails(@PathVariable Long payrollId)
      throws IOException {
    return payrollService.getAllOverrideDetails(payrollId);
  }
}
