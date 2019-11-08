package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class ProjectProcessStep {

  private Long projectProcessStepId, statusId, processStepId;

  private String owner, name, status;

  private LocalDate dateModified;

  private LocalDate completionDate;

  List<ProcessStepAction> actions;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}
