package com.albatross.api.v1.flow.model.smsTeam;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;


/** Created by John Berns on 2022-01-25. !Describe Purpose! */
@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SmsOwner {

  private Long smsTeamId, userId;
  private String teamName, userFirstName, userLastName;
}
