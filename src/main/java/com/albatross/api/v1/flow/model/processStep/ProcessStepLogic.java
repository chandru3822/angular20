package com.albatross.api.v1.flow.model.processStep;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepLogic {

  private Long id, processStepRequirementId, operationTypeId, createdById, modifiedById, sqlOrder, requirementNbr;
  private String operationType, operationCode;
  private Boolean archived, processStepRequirementImmutable;
}

