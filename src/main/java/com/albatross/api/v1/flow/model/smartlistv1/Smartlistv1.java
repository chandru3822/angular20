package com.albatross.api.v1.flow.model.smartlistv1;

import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
@Deprecated
public class Smartlistv1 {

  private Long id,
      companyObjectTypeId,
      ownerId,
      createdById,
      modifiedById,
      objectTypeId,
      viewObjectTypeId,
      workQueueTypeId;
  private String name, objectType, viewObjectType, owner;
  private boolean shared, archived, mainProcessSteps, projectDetails, primaryUserPosition;
  private Timestamp dateCreated, dateModified;

  // workQueueTypes is used only for workqueue generation
  @JsonIgnore private List<ProcessStepEventWorkQueueType> eventWorkQueueTypes;
}
