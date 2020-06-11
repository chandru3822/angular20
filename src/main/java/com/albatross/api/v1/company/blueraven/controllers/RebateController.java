package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.chase_bank.ChaseBankService;
import com.albatross.api.v1.company.blueraven.models.RebateBatchDetail;
import com.albatross.api.v1.company.blueraven.models.RebatePayment;
import com.albatross.api.v1.company.blueraven.models.RebatePaymentState;
import com.albatross.api.v1.company.blueraven.services.RebateService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by John Berns on 2020-04-21.
 */
@Slf4j
@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/rebate")
public class RebateController {
  @Autowired
  private RebateService rebateService;

  @Autowired
  private ChaseBankService chaseService;

  @GetMapping(value = "/pending")
  public List<RebatePayment> getPending() {
    return rebateService.getPending();
  }

  @GetMapping(value = "/unbalancedPayments")
  public List<RebatePayment> getUnbalancedPayments() {
    return rebateService.getUnbalancedPayments();
  }

  @GetMapping(value = "/needsApproval")
  public List<RebatePayment> getNeedsApproval() {
    return rebateService.getNeedsApproval();
  }

  @GetMapping(value = "/details/{id}")
  public String getRebateDetails(@PathVariable("id") Long projectId) {
    return rebateService.getRebateDetails(projectId);
  }

  @GetMapping(value = "/getBatchDetails/{id}")
  public Optional<RebateBatchDetail> getBatchDetails(@PathVariable("id") Long batchId) {
    return rebateService.getBatchDetails(batchId);
  }

  @GetMapping(value="/getBatchDetails/{id}/chase-csv")
  public ResponseEntity<?> getCsvForBatch (@NonNull @PathVariable("id") Long batchId) {
    try {
      return ResponseEntity.ok(chaseService.generateCsv_Ap6DelimitedSingleLine(batchId));
    } catch (ChaseBankService.BadDataException e) {
      log.info("Failed to generate CSV; encountered {} data validation errors.", e.getFailures().size());
      return ResponseEntity.badRequest().body(e.toCsv());
    } catch (Exception e) {
      String msg = "Encountered an error while exported CSV for batch " + batchId;
      log.error(msg + "; " + e.getMessage());
      return ResponseEntity.status(500).body(msg);
    }
  }

  @GetMapping(value = "/getBatches")
  public List<RebateBatchDetail> getAllBatches() {
    return rebateService.getAllBatches();
  }

  @RequestMapping(value = "/voidBatch/{id}", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public Optional<RebateBatchDetail> voidBatch(@PathVariable("id") Long batchId) {
    return rebateService.voidBatch(batchId);
  }

  @RequestMapping(value = "/voidPayment", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public void voidPayment(@RequestBody RebatePayment rebatePayment) {
    rebateService.voidSinglePayment(rebatePayment);
  }

  @RequestMapping(value = "/updateNote", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public void updatePaymentNote(@RequestBody RebatePayment rebatePayment) {
    rebateService.updatePaymentNote(rebatePayment);
  }

  @GetMapping(value = "/getPaymentStates")
  public List<RebatePaymentState> getPaymentStates() {
    return rebateService.getPaymentStates();
  }

  @RequestMapping(value = "/recurringPayment", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public void createRecurringPayment(@RequestBody RebatePayment rebatePayment) {
    rebateService.createRecurringPayment(rebatePayment);
  }

  @RequestMapping(value = "/addExtraPayment", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public void addExtraPayment(@RequestBody RebatePayment rebatePayment) {
    rebateService.addExtraPayment(rebatePayment);
  }

  @RequestMapping(value = "/approve", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public void approvePayments(@RequestBody RebatePayment rebatePayment) throws Exception {
    try {
      //create a batch and mark payments as processed and set the batch id
      rebateService.assignPaymentsToBatch(rebatePayment);
    } catch (Exception ex) {
      log.error("WELLS_FARGO: Failed to fully process batch", ex);
      throw ex;
    }
  }

  @RequestMapping(value = "/updatePayment", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public void updatePayment(@RequestBody RebatePayment rebatePayment) {
    rebateService.updatePayment(rebatePayment);
  }

  @RequestMapping(value = "/updateTotalPromotionAmount", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public void updateTotalPromotionAmount(@RequestBody RebatePayment rebatePayment) {
    rebateService.updateTotalPromotionAmount(rebatePayment);
  }

  @RequestMapping(value = "/deletePayment/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
  public void updatePayment(@PathVariable("id") Long paymentId) {
    rebateService.deletePayment(paymentId);
  }

}
