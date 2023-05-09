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
public class ActivityTypeHashtag {

  private Long id, hashtagId, activityCount;
  private String hashtag;

  private Date lastUpdated;
  private List<Activity> activities;
}

