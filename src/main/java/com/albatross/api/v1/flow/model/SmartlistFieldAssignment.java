package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class SmartlistFieldAssignment {

  //@TODO humes: should probably make this have a field of type SmartlistField since it uses most of those fields anyways

  private Long id, smartlistId, smartlistFieldId, customFieldGroupAssignmentId, createdById, modifiedById, displayOrder, processStepId, dataTypeId, objectTypeId;

  private String name, objectType, processStepName, referenceTable, referenceColumn;

  private Timestamp dateCreated, dateModified;

  private boolean archived;
}
