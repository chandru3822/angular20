package com.albatross.api.v1.flow.model.processStep;

import com.albatross.api.v1.flow.model.DataTypeRequirement;
import com.albatross.api.v1.flow.model.ListOfValue;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

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

  //these are only used for displaying the logic string value of these items
  private String requirementValue, secondaryRequirementValue, operatorType, fieldName, companyFunctionName, parentName,
    referenceProcessStepName, processStepRequirementType;
  private Long processStepRequirementTypeId;
  private DataTypeRequirement dataTypeRequirement;

  //this is the selected item from the list if it was a dropdown
  private ListOfValue listOfValue;

  //this is the selected items from the list if it was a multiselect
  private List<ListOfValue> listOfValues;
}

