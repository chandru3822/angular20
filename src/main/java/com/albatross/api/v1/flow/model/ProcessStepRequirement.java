package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepRequirement {

  private Long id, processStepRequirementTypeId, operatorTypeId, customFieldGroupId, companyFunctionId,
      requirementNbr, processStepId, parentId;
  private String processStepRequirementType, requirementValue, operatorType, parentName, fieldName, companyFunctionName;
  private Boolean archived;
}

