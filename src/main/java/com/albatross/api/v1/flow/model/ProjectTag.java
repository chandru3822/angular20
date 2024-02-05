package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 10/1/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProjectTag {

  private Long id, projectId, tagId;
  private String tagName, fontColor, bgColor, fullNameCreatedBy, fullNameModifiedBy;
  private Date dateCreated, dateModified;
  private Boolean archived;

}

