package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OverrideReceiving {
    private String closerName;
    private Long userId;
    private BigDecimal overrideAmount;
    private String countsForParBonus;
}
