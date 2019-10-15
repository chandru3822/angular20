package com.albatross.api.v1.flow.model;

import java.time.LocalDate;
import java.util.List;

import lombok.Data;

@Data
public class ProjectProcessStep {

  private Long projectProcessStepId, statusId, processStepId;

  private String owner, name, status;

  private LocalDate dateModified;

  private LocalDate completionDate;

  List<ProcessStepAction> actions;
}
