package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class ProjectProcessStep {

  //@TODO: This repeats a lot of the stuff the ProcessStep model does and should probably inherit from it (aka line 16)

  private Long projectProcessStepId, companyStatusId, statusId, processStepId, userPositionId, projectId, workTypeId;

  private String owner, name, status;
  // @humes, didn't want to break anything else you had so i put these 2 here to show some data on the screen
  private String processStepStatusType, processStepName;

  private LocalDate dateModified, lastUpdated;

  private LocalDate completionDate;

  List<ProcessStepAction> actions;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}
