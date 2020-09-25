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
  private String note, createdBy;
  private Boolean archived;

  //wtf!!! why can i not get the frontend to update the dom if this value isn't present on page load?!?!?!
  private Boolean edit;

  private Long primaryId;

  private Date dateCreated;

  private List<Note> childNotes;

}

