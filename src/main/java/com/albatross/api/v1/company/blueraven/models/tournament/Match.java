package com.albatross.api.v1.company.blueraven.models.tournament;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Match {

  private Long id, tournamentRoundId, user1Id, user2Id, user1Score, user2Score;
  private String user1Name, user2Name;
  private Boolean archived, matchAdvanced;

  //dumb dom render stuff I cant figure out so I need this prop for the frontend
  private Long winnerUserId;
}

