package com.albatross.api.v1.flow.model.projectProcessStep;

import lombok.Data;

@Data
public class ProjectProcessStepStatus {

  private Long projectProcessStepId, processStepStatusTypeId, companyProcessStepStatusTypeId;
  private String processStepStatusType, companyProcessStepStatusType;

}
