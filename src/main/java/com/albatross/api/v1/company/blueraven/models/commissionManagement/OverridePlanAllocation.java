package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

@Data
@NoArgsConstructor
public class OverridePlanAllocation {
    private String name, closer, statusType;
    private LocalDate startDate, endDate;
    private BigDecimal total, milestone1Allocation, milestone2Allocation;
    private Map<String, BigDecimal> receivingUsers;
}
