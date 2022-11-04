package com.albatross.api.v1.flow.model.smartlistv2;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class Smartlistv2 {

  private Long id, companyObjectTypeId, ownerId, createdById, modifiedById, objectTypeId, workQueueTypeId;
  private String name, objectType, viewObjectType, owner;
  private boolean shared, archived, mainProcessSteps, projectDetails, primaryUserPosition;
  private Timestamp dateCreated, dateModified;
}
