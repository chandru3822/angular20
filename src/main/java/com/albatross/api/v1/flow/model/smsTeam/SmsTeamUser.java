package com.albatross.api.v1.flow.model.smsTeam;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by John Berns on 2022-01-25.
 * !Describe Purpose!
 */
@Getter
@Setter
public class SmsTeamUser {

  private Long id, smsTeamId, userId;
  private String name;
  private String userName;
  private Boolean archived;
}
