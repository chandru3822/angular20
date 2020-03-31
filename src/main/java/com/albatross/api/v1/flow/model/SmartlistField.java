package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class SmartlistField {

  private Long id, companyObjectTypeId, createdById, modifiedById;

  @JsonIgnore
  private String referenceTable, referenceColumn;

  private String name, objectType;

  private Timestamp dateCreated, dateModified;

  private boolean archived;
}
