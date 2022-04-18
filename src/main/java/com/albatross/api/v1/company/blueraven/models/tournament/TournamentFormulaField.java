package com.albatross.api.v1.company.blueraven.models.tournament;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class TournamentFormulaField {

  private Long id, tournamentFormulaId, dataTypeId, fieldValueId, tournamentId;
  private String fieldName, fieldValue;
  private Boolean archived;
}
