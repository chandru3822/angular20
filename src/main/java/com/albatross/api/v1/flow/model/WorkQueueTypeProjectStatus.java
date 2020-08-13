package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class WorkQueueTypeProjectStatus {

    private Long id, projectStatusTypeId, processStepWorkQueueTypeId;

    private String projectStatusType;

    private Boolean archived;

}
