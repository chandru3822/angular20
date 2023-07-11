package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ActivityHashtag {

  private Long id, createdById, modifiedById, hashtagTypeId, hashtagId;
  private String hashtag, hashtagType;
  private Boolean archived;

  //various object ids
  private Long projectActivityId, contactActivityId, userActivityId, orgActivityId;

  private Date dateCreated, dateModified;

}

