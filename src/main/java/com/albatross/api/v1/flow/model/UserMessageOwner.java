package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by John Berns on 2021-02-03.
 * !Describe Purpose!
 */
@Getter
@Setter
public class UserMessageOwner {

  private Long userId, smsTeamId, ownerUserId;
  private String name;
  private boolean archived;
}
