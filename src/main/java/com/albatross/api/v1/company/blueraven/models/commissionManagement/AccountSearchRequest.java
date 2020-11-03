package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Data;

import java.util.List;

/**
 *
 */
@Data
public class AccountSearchRequest {
    private Integer payrollId;
    private Boolean locked;
    private Long projectId;
    private Long customerId;
    private Long salesRepId;
    private String periodEnd;
    private String cancelStartDate;
    private String cancelEndDate;
    private Long overridePlanId;
    private Long commissionPlanId;
    private List<Long> selectedProjectIds;
}
