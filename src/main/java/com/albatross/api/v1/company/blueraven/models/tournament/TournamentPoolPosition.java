package com.albatross.api.v1.company.blueraven.models.tournament;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class TournamentPoolPosition {

  private Long id, tournamentPoolId, positionId;
  private String position;
  private Boolean archived;
}

