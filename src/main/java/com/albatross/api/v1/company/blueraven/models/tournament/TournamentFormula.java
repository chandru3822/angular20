package com.albatross.api.v1.company.blueraven.models.tournament;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class TournamentFormula {

  private Long id, tournamentOwnerTypeId;
  private String formulaTitle, formulaDescription;
  private Boolean archived;
}

