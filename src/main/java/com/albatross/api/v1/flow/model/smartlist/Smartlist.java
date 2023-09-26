package com.albatross.api.v1.flow.model.smartlist;

import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.smartlistv1.Smartlistv1;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class Smartlist {

  private Long id, companyObjectTypeId, companyId, ownerId, createdById, modifiedById, objectTypeId, workQueueTypeId, accessControlId;
  private String name, objectType, viewObjectType, owner, ownerPosition, accessLevel;
  private boolean isPublic, archived, mainProcessSteps, projectDetails, primaryUserPosition;
  private Timestamp dateCreated, dateModified, dateLastExported;

  private List<SmartlistAccessControl> accessControl;

  // workQueueTypes is used only for workqueue generation
  @JsonIgnore
  private List<ProcessStepEventWorkQueueType> eventWorkQueueTypes;

  // @TODO: #smartlistsv2 - temp until v1 is gone
  public Smartlistv1 toV1(ObjectMapper om) {
    Smartlistv1 smartlist = om.convertValue(this, Smartlistv1.class);
    smartlist.setEventWorkQueueTypes(this.getEventWorkQueueTypes());
    return smartlist;
  }
}
