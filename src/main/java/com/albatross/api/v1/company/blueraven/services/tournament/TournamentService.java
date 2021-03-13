package com.albatross.api.v1.company.blueraven.services.tournament;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.tournament.Bracket;
import com.albatross.api.v1.company.blueraven.models.tournament.Match;
import com.albatross.api.v1.company.blueraven.models.tournament.Tournament;
import com.albatross.api.v1.company.blueraven.models.tournament.TournamentOwnerType;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.AttachmentService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Randa Nunn on 2021-03-12.
 */
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class TournamentService {

  @Value("${aws.storageBucket}")
  private String bucket;

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final AttachmentService attachmentService;
  private final ObjectMapper om;

  public List<Tournament> getTournaments() {
    List<Tournament> results = sqlCache.query("tournament.getTournaments", Collections.emptyMap(), Tournament.class);
    return results;
  }

  public List<TournamentOwnerType> getTournamentOwnerTypes() {
    List<TournamentOwnerType> results = sqlCache.query("tournament.getOwnerTypes", Collections.emptyMap(), TournamentOwnerType.class);
    return results;
  }

  public void deleteTournament(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("id", id);

    sqlCache.update("tournament.delete", params);
  }

  public Optional<Tournament> updateTournament(Tournament tournament) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("id", tournament.getId());
    params.put("tournamentName", tournament.getTournamentName());
    params.put("tournamentOwnerTypeId", tournament.getTournamentOwnerTypeId());
    params.put("startDate", tournament.getStartDate());
    params.put("endDate", tournament.getEndDate());

    Long id = sqlCache.updateReturningId("tournament.update", params, "id").longValue();
    return getTournament(id);
  }

  public Optional<Tournament> addTournament(Tournament tournament) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("tournamentName", tournament.getTournamentName());
    params.put("tournamentOwnerTypeId", tournament.getTournamentOwnerTypeId());
    params.put("startDate", tournament.getStartDate());
    params.put("endDate", tournament.getEndDate());

    Long id = sqlCache.updateReturningId("tournament.insert", params, "id").longValue();
    return getTournament(id);
  }

  public List<Tournament> getActiveTournaments() {
    List<Tournament> results = sqlCache.query("tournament.getActiveTournaments", Collections.emptyMap(), Tournament.class);
    return results;
  }

  public Optional<Tournament> getTournament(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<Tournament> result = sqlCache.get("tournament.get", params, new TournamentMapper<>(Tournament.class, om));
    if(result.isPresent() && null != result.get().getBackgroundAttachmentId()) {
      result.get().setBackgroundAttachmentPresignedUrl(attachmentService.getAttachmentPresignedUrlById(bucket, result.get().getBackgroundAttachmentId()));
    }
    return result;
  }

  public void advanceMatches(List<Match> matches) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());

    for(Match m : matches) {
      //advance each match
      params.put("matchId", m.getId());
      params.put("winnerUserId", m.getWinnerUserId());
      sqlCache.update("tournament.advanceMatch", params);
    }
  }


  public static class TournamentMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public TournamentMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Bracket>> bracketsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "brackets",
        new JsonCollectionDeserializer(bracketsRef, objectMapper));
    }
  }
}
