package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class Smartlist {

  private Long id, companyObjectTypeId, ownerId, createdById, modifiedById, objectTypeId;

  private String name, objectType;

  private boolean shared, archived;

  private Timestamp dateCreated, dateModified;
}
