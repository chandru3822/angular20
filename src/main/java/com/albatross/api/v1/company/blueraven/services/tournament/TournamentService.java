package com.albatross.api.v1.company.blueraven.services.tournament;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.tournament.*;
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

  public List<TournamentFormula> getTournamentFormulas(Long ownerTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ownerTypeId", ownerTypeId);
    List<TournamentFormula> results = sqlCache.query("tournament.getFormulas", params, TournamentFormula.class);
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
    params.put("active", null != tournament.getActive() ? tournament.getActive() : false);

    Long id = sqlCache.updateReturningId("tournament.update", params, "id").longValue();
    return getTournament(id);
  }

  public Optional<Tournament> addTournament(Tournament tournament) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("tournamentName", tournament.getTournamentName());
    params.put("tournamentOwnerTypeId", tournament.getTournamentOwnerTypeId());
    params.put("tournamentFormulaId", tournament.getTournamentFormulaId());
    params.put("startDate", tournament.getStartDate());
    params.put("endDate", tournament.getEndDate());

    // this also adds a qualifying, loser and winner pool
    Long id = sqlCache.queryForObject("tournament.insert", params, Long.class);
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

  public String getBrackets(Long tournamentId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentId", tournamentId);

    String results = sqlCache.queryForObject("tournament.getBrackets", params, String.class);
    return results;
  }

  public Optional<Bracket> getBracket(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<Bracket> result = sqlCache.get("tournament.getBracket", params, new BracketMapper<>(Bracket.class, om));
    return result;
  }

  public Optional<Bracket> addBracket(Bracket bracket) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("numberOfUsers", bracket.getNumberOfUsers());
    params.put("tournamentId", bracket.getTournamentId());
    params.put("createdById", user.getId());

    Long id = sqlCache.updateReturningId("tournament.addBracket", params, "id").longValue();
    return getBracket(id);
  }


  public Optional<Bracket> replicateBracket(Bracket bracket) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("numberOfUsers", bracket.getNumberOfUsers());
    params.put("tournamentId", bracket.getTournamentId());
    params.put("createdById", user.getId());

    Long id = sqlCache.updateReturningId("tournament.addBracket", params, "id").longValue();

    for(Round round : bracket.getRounds()) {
      round.setTournamentBracketId(id);
      saveRound(round, true);
    }
    return getBracket(id);
  }


  public void deleteBracket(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("id", id);

    sqlCache.update("tournament.deleteBracket", params);
  }

  public Optional<Bracket> saveRound(Round round, Boolean replicate) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("bracketId", round.getTournamentBracketId());
    params.put("startDate", round.getStartDate());
    params.put("endDate", round.getEndDate());
    params.put("userId", user.getId());

    //if replicating then always insert
    if(null != round.getId() && !replicate) {
      params.put("id", round.getId());
      sqlCache.update("tournament.updateRound", params);
    } else {
      sqlCache.update("tournament.addRound", params);
    }

    //return the bracket because the sort order of the rounds may have changed
    return getBracket(round.getTournamentBracketId());
  }

  public Optional<Bracket> deleteRound(Round round) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("id", round.getId());

    sqlCache.update("tournament.deleteRound", params);
    return getBracket(round.getTournamentBracketId());
  }

  public void generateMatches(Long bracketId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("bracketId", bracketId);

    sqlCache.query("tournament.generateMatches", params, String.class);
  }

  public void advanceWinners(Long tournamentId, Long roundId, List<Match> matches) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());

    for(Match m : matches) {
      //advance each match
      params.put("matchId", m.getId());
      params.put("roundId", roundId);
      params.put("user1Score", m.getUser1Score());
      params.put("user2Score", m.getUser2Score());
      params.put("tournamentId", tournamentId);
      sqlCache.update("tournament.advanceWinners", params);
    }
  }

  public void advanceMatches(List<Match> matches) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());

    for(Match m : matches) {
      //advance each match
      params.put("matchId", m.getId());
      params.put("parentMatchId", m.getParentMatchId());
      params.put("user1Score", m.getUser1Score());
      params.put("user2Score", m.getUser2Score());
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
      TypeReference<List<Bracket>> bracketsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "brackets",
        new JsonCollectionDeserializer(bracketsRef, objectMapper));

      TypeReference<List<TournamentPool>> poolsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "pools",
        new JsonCollectionDeserializer(poolsRef, objectMapper));
    }
  }

  public static class BracketMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public BracketMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Round>> roundsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "rounds",
        new JsonCollectionDeserializer(roundsRef, objectMapper));
    }
  }
}
