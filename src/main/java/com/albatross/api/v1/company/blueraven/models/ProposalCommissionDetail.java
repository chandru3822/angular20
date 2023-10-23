package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProposalCommissionDetail {
  private Double redlineAmount, sourceDiscount, addersDollarWatts, basePrice, commissionsDollarWatts,
    totalPpw, systemSize, cashPrice, loanAmount, monthlyPayment, commissionKw, totalCommissions;

}
