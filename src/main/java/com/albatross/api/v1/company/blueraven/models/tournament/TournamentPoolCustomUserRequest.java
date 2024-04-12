package com.albatross.api.v1.company.blueraven.models.tournament;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class TournamentPoolCustomUserRequest {

  private Long minFdc, maxFdc;
  private Date minDate, maxDate;
  private Boolean inclusive;
}

