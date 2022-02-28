package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Note {

  private Long id, parentId, createdById;
  private String note, createdBy, installDashTile, followUpDate;
  private Boolean archived;
  private UserPosition createdByPrimaryPosition;

  //wtf!!! why can i not get the frontend to update the dom if this value isn't present on page load?!?!?!
  private Boolean edit;

  private Long primaryId;

  //it bugs me that i have to add these for the ppsqwt note that needs 2 primary ids
  private Long projectProcessStepId, processStepWorkQueueTypeId, projectProcessStepEventId, processStepEventWorkQueueTypeId;

  private Date dateCreated;

  private List<Note> childNotes;

}

