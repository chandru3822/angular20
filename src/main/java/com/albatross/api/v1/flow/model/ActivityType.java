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
public class ActivityType {

  private Long id, displayOrder;
  private String activityType;
  private List<ActivityTypeHashtag> activityHashtags;

}

