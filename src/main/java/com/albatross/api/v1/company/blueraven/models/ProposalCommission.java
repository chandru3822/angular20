package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class ProposalCommission {
  private Long proposalId;
  private Double apr, loanTerm;
  private String monthlyCostTodayWithoutSolar;
  private List<ProposalCommissionDetail> commissionDetails;
}
