package com.albatross.api.v1.flow.model.workQueue;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueueMetric {
    private Long workQueueTypeId, shortWindowExited, longWindowExited;
    private String shortWindowDurationType, longWindowDurationType, expectedCycleDurationType;
    private Double shortWindowPercentage, longWindowPercentage, shortWip, longWip, expectedTarget;
}
