package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class ProjectProcessStep {

  //@TODO: This repeats a lot of the stuff the ProcessStep model does and should probably inherit from it

  private Long projectProcessStepId, processStepId, userPositionId, projectId, processStepStatusTypeId;

  private String owner, processStepName, processStepStatusType;

  private LocalDate lastUpdated, processStepCompleteDate;

  List<ProcessStepAction> actions;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}
