package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class SmartlistFieldAssignment {

  private Long id, smartlistId, smartlistFieldId, customFieldId, createdById, modifiedById, displayOrder;

  private String name, objectType;

  private Timestamp dateCreated, dateModified;

  private boolean archived;
}
