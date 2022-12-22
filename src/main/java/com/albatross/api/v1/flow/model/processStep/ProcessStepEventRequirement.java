package com.albatross.api.v1.flow.model.processStep;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.DataTypeRequirement;
import com.albatross.api.v1.flow.model.event.EventRequirementParamDynamicValue;
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
public class ProcessStepEventRequirement {

  private Long id, processStepEventId, eventId, processStepRequirementTypeId, operatorTypeId, customFieldGroupAssignmentId, companyFunctionId,
    requirementNbr, processStepId, parentId, dataTypeId, dataTypeRequirementId, listOfValueId, returnDataTypeId,
    companySystemListId, systemListOptionId, customSqlOptionId, referenceProcessStepId;

  private String processStepRequirementType, requirementValue, operatorType, parentName, fieldName, companyFunctionName, functionName, processStepName,
    secondaryRequirementValue, customFieldSql, referenceProcessStepName;

  // not sure what type to make this yet
  private List<Integer> listOfValueIds;
  private List<Long> systemListOptionIds;

  // todo: this is my hibernate-y disaster. figure this out
  //this is the selected item from the list if it was a dropdown
  private ListOfValue listOfValue;

  //this is the selected items from the list if it was a multiselect
  private List<ListOfValue> listOfValues;

  //this is the available items for the list (works for dropdown, multi, system list, and custom sql)
  private List<ListOfValue> availableListOfValues;

  private DataTypeRequirement dataTypeRequirement;
  private List<EventRequirementParamDynamicValue> requirementParamDynamicValues;

  //i need this so i can determine what type of field is being used when EDITING a custom field
  private CustomField customField;

  private Boolean archived, fulfilled, secondaryRequirement, customValue, immutable, failIfNoReferenceStepFound;
}

