package com.albatross.api.v1.flow.model;

import lombok.Data;

@Data
public class ProjectProcessStepStatus {

  private Long projectProcessStepId, processStepStatusTypeId, companyProcessStepStatusTypeId;
  private String processStepStatusType, companyProcessStepStatusType;

}
