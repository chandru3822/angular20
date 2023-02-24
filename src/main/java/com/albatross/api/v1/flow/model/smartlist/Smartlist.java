package com.albatross.api.v1.flow.model.smartlist;

import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.smartlistv1.Smartlistv1;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class Smartlist {

  private Long id, companyObjectTypeId, companyId, ownerId, createdById, modifiedById, objectTypeId, workQueueTypeId, accessControlId;
  private String name, objectType, viewObjectType, owner, accessLevel, modifiedBy, createdBy;
  private boolean isPublic, archived, mainProcessSteps, projectDetails, primaryUserPosition;
  private Timestamp dateCreated, dateModified;

  private List<SmartlistAccessControl> accessControl;

  // workQueueTypes is used only for workqueue generation
  @JsonIgnore
  private List<ProcessStepEventWorkQueueType> eventWorkQueueTypes;

  public Smartlistv1 toOriginal() {
    Smartlistv1 smartlist = new Smartlistv1();
    smartlist.setId(this.getId());
    smartlist.setCompanyObjectTypeId(this.getCompanyObjectTypeId());
    smartlist.setOwnerId(this.getOwnerId());
    smartlist.setCreatedById(this.getCreatedById());
    smartlist.setModifiedById(this.getModifiedById());
    smartlist.setObjectTypeId(this.getObjectTypeId());
    smartlist.setViewObjectTypeId(null);
    smartlist.setWorkQueueTypeId(this.getWorkQueueTypeId());
    smartlist.setName(this.getName());
    smartlist.setObjectType(this.getObjectType());
    smartlist.setViewObjectType("");
    smartlist.setOwner(this.getOwner());
    smartlist.setShared(this.isPublic);
    smartlist.setArchived(this.archived);
    smartlist.setMainProcessSteps(this.mainProcessSteps);
    smartlist.setProjectDetails(this.projectDetails);
    smartlist.setPrimaryUserPosition(this.primaryUserPosition);
    smartlist.setDateCreated(this.getDateCreated());
    smartlist.setDateModified(this.getDateModified());
    smartlist.setEventWorkQueueTypes(this.getEventWorkQueueTypes());

    return smartlist;
  }
}
