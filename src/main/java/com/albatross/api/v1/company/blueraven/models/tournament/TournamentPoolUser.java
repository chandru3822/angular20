package com.albatross.api.v1.company.blueraven.models.tournament;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class TournamentPoolUser {

  private Long id, tournamentPoolId, userId;
  private String fullName;
  private Boolean archived;
}

