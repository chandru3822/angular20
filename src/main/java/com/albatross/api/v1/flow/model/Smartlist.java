package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class Smartlist {

  private Long id, companyObjectTypeId, ownerId, createdById, modifiedById, objectTypeId, viewObjectTypeId, workQueueTypeId;

  private String name, objectType, viewObjectType, owner;

  private boolean shared, archived, mainProcessSteps, projectDetails, primaryUserPosition;

  private Timestamp dateCreated, dateModified;

  private List<Long> workQueueTypeProjectStatus, workQueueTypeProjectCategory, workQueueTypeProcessStepStatus, workQueueTypeProcessStepCategory,
                     workQueueTypeEventStatus, workQueueTypeEventCategory;
}
