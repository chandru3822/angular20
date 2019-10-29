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
    requirementNbr, processStepId, parentId, dataTypeId, dataTypeRequirementId, listOfValueId, returnDataTypeId;

  private String processStepRequirementType, requirementValue, operatorType, parentName, fieldName, companyFunctionName, functionName, processStepName,
    secondaryRequirementValue;

  // not sure what type to make this yet
  private List<Integer> listOfValueIds;

  //this is the selected item from the list if it was a dropdown
  private ListOfValue listOfValue;

  //this is the selected items from the list if it was a multiselect
  private List<ListOfValue> listOfValues;

  private DataTypeRequirement dataTypeRequirement;
  private List<RequirementParamDynamicValue> requirementParamDynamicValues;

  private Boolean archived, fulfilled, secondaryRequirement, customValue, immutable;
}

