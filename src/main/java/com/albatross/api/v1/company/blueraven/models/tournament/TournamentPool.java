package com.albatross.api.v1.company.blueraven.models.tournament;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class TournamentPool {

  private Long id, tournamentPoolTypeId;
  private String poolType;
  private Date startDate, endDate;
  private Boolean archived;
  private List<TournamentPoolUser> users;
  private List<TournamentPoolPosition> positions;
}

