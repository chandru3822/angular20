package com.albatross.api.v1.company.blueraven.controllers.commissionManagement;

import com.albatross.api.v1.company.blueraven.models.commissionManagement.AccountSearchRequest;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.PayrollService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/commissionManagement/accountReview")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class AccountReviewController {

    private final PayrollService payrollService;

    @PostMapping(value = "/search")
    public ResponseEntity<String> getAccountingReview(@RequestBody AccountSearchRequest request) {
        try {
            String accountReview = payrollService.getAccountReview(request);
            return ResponseEntity.ok(accountReview);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }
}
