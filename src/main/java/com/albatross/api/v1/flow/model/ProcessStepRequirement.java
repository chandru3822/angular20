package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepRequirement {

  private Long id, processStepRequirementTypeId, operatorTypeId, customFieldGroupAssignmentId, companyFunctionId,
      requirementNbr, processStepId, parentId, dataTypeId;

  private String processStepRequirementType, requirementValue, operatorType, parentName, fieldName, companyFunctionName, processStepName,
                  secondaryRequirementValue;

  private List<RequirementParamDynamicValue> requirementParamDynamicValues;

  private Boolean archived, fulfilled;

  private boolean secondaryRequirement, isDataTypeRequirement;
}

