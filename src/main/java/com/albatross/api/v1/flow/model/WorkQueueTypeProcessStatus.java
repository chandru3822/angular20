package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class WorkQueueTypeProcessStatus {

    private Long id, companyProcessStepStatusTypeId, processStepStatusTypeId, processStepWorkQueueTypeId;

    private String processStepStatusType;

    private Boolean archived;

}
