package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class SmartlistFieldAssignment {

  private Long id, smartlistId, smartlistFieldId, customFieldGroupAssignmentId, createdById, modifiedById, displayOrder, processStepId, dataTypeId;

  private String name, objectType, processStepName;

  private Timestamp dateCreated, dateModified;

  private boolean archived;
}
