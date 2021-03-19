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
public class Tournament {

  private Long id, tournamentOwnerTypeId, backgroundAttachmentId;
  private String tournamentName, ownerType, backgroundAttachmentPresignedUrl;
  private Date startDate, endDate;
  private Boolean archived;
  private List<Bracket> brackets;
  private List<TournamentPool> pools;
}

