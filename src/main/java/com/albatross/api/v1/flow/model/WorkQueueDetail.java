package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueueDetail {
    private Long processStepId, companyId, projectProcessStepId, projectId, customerId;
    private String projectName, workQueueType, processStepName, owner, lastUpdated;
    private List<OwningPosition> owningPositions;
}
