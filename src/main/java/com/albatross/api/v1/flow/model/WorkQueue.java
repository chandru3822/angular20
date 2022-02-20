package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueue {
    private Long workQueueTypeId, workQueueCategoryId, companyId, workQueueCount, smartlistId,
      shortWindow, longWindow, expectedCycle, shortWindowExited, longWindowExited;
    private String workQueueType, color, shortWindowDurationType, longWindowDurationType, expectedCycleDurationType;
    private Double shortWindowPercentage, longWindowPercentage, shortWip, longWip, expectedTarget;
    private Boolean archived, inverseExpectation, useEventData;
}
