package com.albatross.api.v1.flow.model.processStep;

import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeEventStatus;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProcessStepStatus;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProjectStatus;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class ProcessStepEventWorkQueueType {
    private Long id, processStepId, processStepEventId, workQueueTypeId, workQueueCategoryId;
    private String workQueueType, workQueueCategory, projectStatusType;
    private Boolean archived;
    private List<WorkQueueTypeProjectStatus> projectStatuses;
    private List<WorkQueueTypeProcessStepStatus> processStepStatuses;
    private List<WorkQueueTypeEventStatus> eventStatuses;
}
