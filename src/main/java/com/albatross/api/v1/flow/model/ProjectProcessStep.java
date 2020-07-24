package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class ProjectProcessStep {

  //@TODO: This repeats a lot of the stuff the ProcessStep model does and should probably inherit from it

  private Long projectProcessStepId, processStepId, projectId, processStepStatusTypeId, processStepProcessId, companyProcessStepStatusTypeId;

  private String processStepName, processStepStatusType;

  private LocalDate lastUpdated, processStepCompleteDate;

  private Boolean main;

  private List<ProcessStepAction> actions;

  private Owner owner;

  //so far this is only used for saving
  // @TODO: Move saving this to the CustomFieldValue controller so this prop can be killed (like how the project level fields are updated)
  List<CustomFieldGroup> customFieldGroups;
}
