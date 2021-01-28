package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class ProcessStepWorkQueueType {
    private Long id, processStepId, workQueueTypeId, workQueueCategoryId;
    private String workQueueType, workQueueCategory, projectStatusType;
    private Boolean archived;
    private List<WorkQueueTypeProjectStatus> projectStatuses;
    private List<WorkQueueTypeProcessStatus> processStepStatuses;
}
