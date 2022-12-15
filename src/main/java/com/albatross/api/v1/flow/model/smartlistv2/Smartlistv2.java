package com.albatross.api.v1.flow.model.smartlistv2;

import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.smartlist.Smartlist;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class Smartlistv2 {

  private Long id, companyObjectTypeId, ownerId, createdById, modifiedById, objectTypeId, workQueueTypeId;
  private String name, objectType, viewObjectType, owner;
  private boolean isPublic, archived, mainProcessSteps, projectDetails, primaryUserPosition;
  private Timestamp dateCreated, dateModified;

  // workQueueTypes is used only for workqueue generation
  @JsonIgnore
  private List<ProcessStepEventWorkQueueType> eventWorkQueueTypes;

  public Smartlist toOriginal() {
    Smartlist smartlist = new Smartlist();
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
