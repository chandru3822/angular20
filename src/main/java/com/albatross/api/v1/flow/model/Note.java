package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

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

  private Long primaryId;

  //dates as strings or dates???
  private String dateCreated;

  private List<Note> childNotes;

}

