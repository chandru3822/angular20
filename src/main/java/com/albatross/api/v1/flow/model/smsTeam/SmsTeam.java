package com.albatross.api.v1.flow.model.smsTeam;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/** Created by John Berns on 2022-01-25. !Describe Purpose! */
@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SmsTeam {

  private Long id;
  private String teamName;
  private Boolean archived, isDefault, defaultExists;
  private List<SmsTeamUser> users;
  private List<SmsTeamPosition> positions;
  private List<SmsTeamOrg> orgs;
}
