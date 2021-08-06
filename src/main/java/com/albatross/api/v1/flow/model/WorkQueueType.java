package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueueType {
    private Long id, companyId, workQueueCategoryId, displayOrder,
      workQueueCategoryDisplayOrder, smartlistId, longWindow, shortWindow, longWindowDurationTypeId,
      shortWindowDurationTypeId, expectedCycle, expectedCycleDurationTypeId;
    private String workQueueType, workQueueCategory, workQueueCategoryColor,
      longWindowDurationType, shortWindowDurationType, expectedCycleDurationType;
    private Double expectedTarget;
    private Boolean archived, inverseExpectation;
}
