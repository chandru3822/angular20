package com.albatross.api.v1.company.blueraven.models.tournament;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Bracket {

  private Long id, tournamentId, numberOfUsers;
  private Boolean archived, matchesGenerated;
  private List<Round> rounds;
}

