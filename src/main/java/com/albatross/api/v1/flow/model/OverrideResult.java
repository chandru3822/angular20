package com.albatross.api.v1.flow.model;

import lombok.Data;

@Data
public class OverrideResult {
    private String closer, customerName, overridePlanName;
    private Long projectId;
    private Double systemSize, overridesEarned, priorPay, currentPay, userAllocation,
      milestone1Percentage, milestone2Percentage, planTotal ;
}
