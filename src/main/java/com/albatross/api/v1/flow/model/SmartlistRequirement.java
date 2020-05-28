package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class SmartlistRequirement {

  //@TODO humes: should probably make this have a field of type SmartlistField since it uses most of those fields anyways

  private Long id, smartlistId, smartlistFieldId, processStepId, customFieldGroupAssignmentId, operatorTypeId, objectTypeId,
               dataTypeId, dataTypeRequirementId, displayOrder, createdById, modifiedById, companySystemListId, listOfValueId, systemListOptionId, customSqlOptionId;

  private String requirementValue, secondaryRequirementValue, processStepName, objectType, operatorType, name, referenceTable, referenceColumn, customFieldSqlKey;

  private Timestamp dateCreated, dateModified;

  private Boolean immutable, archived, hasListValues;

  private List<Long> listOfValueIds, systemListOptionIds;

  private List<ListOfValue> listOfValues, availableListOfValues;

  private DataTypeRequirement dataTypeRequirement;
}
