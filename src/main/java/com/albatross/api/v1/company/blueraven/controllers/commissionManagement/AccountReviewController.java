package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.AccountSearchRequest;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.PayrollService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Hidden
@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/commissionManagement/accountReview")
@RequiredArgsConstructor
public class AccountReviewController {

  private final PayrollService payrollService;

  @PostMapping(value = "/search")
  public ResponseEntity<String> getAccountingReview(@RequestBody AccountSearchRequest request) {
    try {
      String accountReview = payrollService.getAccountReview(request);
      return ResponseEntity.ok(accountReview);
    } catch (Exception e) {
      log.error("COMMISSION: payroll get account error", e);
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
    }
  }
}
