package com.albatross.api.v1.flow.model;

import java.time.LocalDate;

import lombok.Data;

@Data
public class ProjectProcessStep {

  private Long projectProcessStepId, companyProcessId, processStepStatusTypeId;

  private String owner, processStepName, processStepStatusType;

  private LocalDate lastUpdated;
}