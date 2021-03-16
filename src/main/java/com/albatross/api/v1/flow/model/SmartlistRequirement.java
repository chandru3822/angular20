package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class SmartlistRequirement {

  //@TODO humes: should probably make this have a field of type SmartlistField since it uses most of those fields anyways

  private Long id, smartlistId, smartlistFieldId, processStepId, customFieldGroupAssignmentId, operatorTypeId, objectTypeId,
               dataTypeId, dataTypeRequirementId, displayOrder, createdById, modifiedById, companySystemListId, systemListId, listOfValueId, systemListOptionId, customSqlOptionId,
               smartlistSystemListId, companyId;

  private String requirementValue, secondaryRequirementValue, processStepName, objectType, operatorType, name, customFieldSqlKey, projectDetailsColumn;

  private Timestamp dateCreated, dateModified;

  private Boolean immutable, archived, hasListValues, isCustomValue, allowMultiple;

  private List<Long> listOfValueIds, systemListOptionIds;

  private List<ListOfValue> listOfValues, availableListOfValues;

  private DataTypeRequirement dataTypeRequirement;

  @JsonIgnore
  private String referenceTable, referenceColumn, valueReferenceTable, joinTable, joinColumn;

  @JsonIgnore
  private CustomField customField;
}
