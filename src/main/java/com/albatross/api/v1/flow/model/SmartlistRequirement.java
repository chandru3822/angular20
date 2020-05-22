package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class SmartlistRequirement {

  //@TODO humes: should probably make this have a field of type SmartlistField since it uses most of those fields anyways

  private Long id, smartlistId, smartlistFieldId, processStepId, customFieldGroupAssignmentId, operatorTypeId, objectTypeId, dataTypeId, dataTypeRequirementId, displayOrder, createdById, modifiedById;

  private String requirementValue, secondaryRequirementValue, processStepName, objectType, operatorType, name, referenceTable, referenceColumn;

  private Timestamp dateCreated, dateModified;

  private Boolean immutable, archived;

  private DataTypeRequirement dataTypeRequirement;
}
