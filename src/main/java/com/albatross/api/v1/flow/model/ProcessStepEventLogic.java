package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepEventLogic {

  private Long id, processStepEventRequirementId, operationTypeId, createdById, modifiedById, sqlOrder, requirementNbr;
  private String operationType, operationCode;
  private Boolean archived, processStepRequirementImmutable;
}

