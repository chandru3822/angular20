package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class SmartlistRequirement {

  private Long id, smartlistId, smartlistFieldId, processStepId, customFieldGroupAssignmentId, operatorTypeId, objectTypeId, dataTypeId, dataTypeRequirementId, displayOrder, createdById, modifiedById;

  private String requirementValue, secondaryRequirementValue, processStepName, objectType, operatorType, name;

  private Timestamp dateCreated, dateModified;

  private Boolean immutable, archived;

  private DataTypeRequirement dataTypeRequirement;
}
