package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by John Berns on 2021-02-03.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProjectMessageOwner {

  private Long projectId, smsTeamId, userId;
  private String name;
  private boolean archived;
}
