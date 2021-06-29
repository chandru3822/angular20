package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class Smartlist {

  private Long id, companyObjectTypeId, ownerId, createdById, modifiedById, objectTypeId, viewObjectTypeId, workQueueTypeId;

  private String name, objectType, viewObjectType, owner;

  private boolean shared, archived, mainProcessSteps, projectDetails;

  private Timestamp dateCreated, dateModified;
}
