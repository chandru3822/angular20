package com.albatross.api.v1.flow.model.projectProcessStep;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProjectProcessStepHistory {

    private Long id, projectProcessStepId, projectId, processStepId, userPositionId, modifiedById, createdById;
    private String owner, createdBy, modifiedBy, companyProcessStepStatusType,
      processStepStatusType, dateCreated, dateModified;
    private Boolean main, archived;
}
