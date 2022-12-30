package com.albatross.api.v1.company.blueraven.services.tournament;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.tournament.*;
import com.albatross.api.v1.company.blueraven.services.tournament.queries.TournamentQuery;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.AttachmentService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Randa Nunn on 2021-03-12.
 */
@Service
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccessLevel('TOURNAMENTS')")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class TournamentService {

  @Value("${aws.storageBucket}")
  private String bucket;

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final AttachmentService attachmentService;
  private final ObjectMapper om;

  public List<Tournament> getTournaments() {
    List<Tournament> results = sqlCache.queryBySql(TournamentQuery.getTournaments, Collections.emptyMap(), Tournament.class);
    return results;
  }

  public String getFormulaColumns(Long tournamentId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentId", tournamentId);
    String result = sqlCache.queryForObjectBySql(TournamentQuery.getFormulaColumns, params, String.class);
    return result;
  }

  public String getUserScores(Long tournamentId, Long userId, String startDate, String endDate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentId", tournamentId);
    params.put("userId", userId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    Optional<String> results = sqlCache.queryForObjectOptionalBySql(TournamentQuery.getUserScores, params, String.class);
    return results.orElse(null);
  }

  public List<TournamentOwnerType> getTournamentOwnerTypes() {
    List<TournamentOwnerType> results = sqlCache.queryBySql(TournamentQuery.getOwnerTypes, Collections.emptyMap(), TournamentOwnerType.class);
    return results;
  }

  public List<TournamentFormula> getTournamentFormulas(Long ownerTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ownerTypeId", ownerTypeId);
    List<TournamentFormula> results = sqlCache.queryBySql(TournamentQuery.getFormulas, params, TournamentFormula.class);
    return results;
  }

  public List<TournamentFormulaField> getTournamentFormulaFields(Long formulaId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("formulaId", formulaId);
    List<TournamentFormulaField> results = sqlCache.queryBySql(TournamentQuery.getFormulaFields, params, TournamentFormulaField.class);
    return results;
  }

  public void deleteTournament(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("id", id);

    sqlCache.updateBySql(TournamentQuery.delete, params);
  }

  public Optional<Tournament> updateTournament(Tournament tournament) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("id", tournament.getId());
    params.put("tournamentName", tournament.getTournamentName());
    params.put("tournamentOwnerTypeId", tournament.getTournamentOwnerTypeId());
    params.put("startDate", tournament.getStartDate());
    params.put("endDate", tournament.getEndDate());
    params.put("active", null != tournament.getActive() ? tournament.getActive() : false);

    //update the tournament itself
    Long id = sqlCache.updateBySqlReturningId(TournamentQuery.update, params, "id").longValue();

    saveTournamentFormulaFields(tournament.getTournamentFormulaFields(), id, user.trueUserId());

    return getTournament(id);
  }

  public void saveTournamentFormulaFields(List<TournamentFormulaField> fields, Long tournamentId, Long userId) {
    for (TournamentFormulaField tff : fields) {
      //if the field came here it was dirty and should always be saved
      HashMap<String, Object> tffParams = new HashMap<>();
      tffParams.put("fieldValue", tff.getFieldValue());
      tffParams.put("fieldId", tff.getId());
      tffParams.put("tournamentId", tournamentId);
      tffParams.put("userId", userId);

      sqlCache.updateBySql(TournamentQuery.saveFieldValue, tffParams);
    }
  }

  public Optional<Tournament> addTournament(Tournament tournament) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("tournamentName", tournament.getTournamentName());
    params.put("tournamentOwnerTypeId", tournament.getTournamentOwnerTypeId());
    params.put("tournamentFormulaId", tournament.getTournamentFormulaId());
    params.put("startDate", tournament.getStartDate());
    params.put("endDate", tournament.getEndDate());

    // this also adds a qualifying, loser and winner pool
    Long id = sqlCache.queryForObjectBySql(TournamentQuery.insert, params, Long.class);

    saveTournamentFormulaFields(tournament.getTournamentFormulaFields(), id, user.trueUserId());

    return getTournament(id);
  }

  public List<Tournament> getActiveTournaments() {
    List<Tournament> results = sqlCache.queryBySql(TournamentQuery.getActiveTournaments, Collections.emptyMap(), Tournament.class);
    return results;
  }

  public Optional<Tournament> getTournament(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<Tournament> result = sqlCache.getBySql(TournamentQuery.get, params, new TournamentMapper<>(Tournament.class, om));
    if(result.isPresent() && null != result.get().getBackgroundAttachmentId()) {
      result.get().setBackgroundAttachmentPresignedUrl(attachmentService.getAttachmentPresignedUrlById(bucket, result.get().getBackgroundAttachmentId()));
    }
    return result;
  }

  public String getBrackets(Long tournamentId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("tournamentId", tournamentId);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String results = sqlCache.queryForObjectBySql(TournamentQuery.getBrackets, params, String.class);
    return results;
  }

  public Optional<Bracket> getBracket(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<Bracket> result = sqlCache.getBySql(TournamentQuery.getBracket, params, new BracketMapper<>(Bracket.class, om));
    return result;
  }

  public Optional<Bracket> addBracket(Bracket bracket) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("numberOfUsers", bracket.getNumberOfUsers());
    params.put("tournamentId", bracket.getTournamentId());
    params.put("createdById", user.trueUserId());

    Long id = sqlCache.updateBySqlReturningId(TournamentQuery.addBracket, params, "id").longValue();
    return getBracket(id);
  }


  public Optional<Bracket> replicateBracket(Bracket bracket) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("numberOfUsers", bracket.getNumberOfUsers());
    params.put("tournamentId", bracket.getTournamentId());
    params.put("createdById", user.trueUserId());

    Long id = sqlCache.updateBySqlReturningId(TournamentQuery.addBracket, params, "id").longValue();

    for(Round round : bracket.getRounds()) {
      round.setTournamentBracketId(id);
      saveRound(round, true);
    }
    return getBracket(id);
  }


  public void deleteBracket(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("id", id);

    sqlCache.updateBySql(TournamentQuery.deleteBracket, params);
  }

  public Optional<Bracket> saveRound(Round round, Boolean replicate) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("bracketId", round.getTournamentBracketId());
    params.put("startDate", round.getStartDate());
    params.put("endDate", round.getEndDate());
    params.put("userId", user.trueUserId());

    //if replicating then always insert
    if(null != round.getId() && !replicate) {
      params.put("id", round.getId());
      sqlCache.updateBySql(TournamentQuery.updateRound, params);
    } else {
      sqlCache.updateBySql(TournamentQuery.addRound, params);
    }

    //return the bracket because the sort order of the rounds may have changed
    return getBracket(round.getTournamentBracketId());
  }

  public Optional<Bracket> deleteRound(Round round) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("id", round.getId());

    sqlCache.updateBySql(TournamentQuery.deleteRound, params);
    return getBracket(round.getTournamentBracketId());
  }

  public void generateMatches(Long bracketId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("bracketId", bracketId);

    sqlCache.queryBySql(TournamentQuery.generateMatches, params, String.class);
  }

  public void advanceWinners(Long tournamentId, Long roundId, List<Match> matches) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());

    for(Match m : matches) {
      //advance each match
      params.put("matchId", m.getId());
      params.put("roundId", roundId);
      params.put("user1Score", m.getUser1Score());
      params.put("user2Score", m.getUser2Score());
      params.put("tournamentId", tournamentId);
      sqlCache.updateBySql(TournamentQuery.advanceWinners, params);
    }
  }

  public void advanceMatches(Long tournamentId, List<Match> matches) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());

    for(Match m : matches) {
      //advance each match
      params.put("matchId", m.getId());
      params.put("parentMatchId", m.getParentMatchId());
      params.put("user1Score", m.getUser1Score());
      params.put("user2Score", m.getUser2Score());
      params.put("winnerUserId", m.getWinnerUserId());
      sqlCache.updateBySql(TournamentQuery.advanceMatch, params);

      //put the losers into the last chance pool
      params.put("tournamentId", tournamentId);
      params.put("loserUserId", m.getWinnerUserId().equals(m.getUser1Id()) ? m.getUser2Id() : m.getUser1Id());
      sqlCache.updateBySql(TournamentQuery.insertLoserToLastChance, params);
    }
  }

  public void overrideMatchUser(Long matchId, Long userId, Boolean overrideUser1) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", user.trueUserId());
    params.put("userId", userId);
    params.put("matchId", matchId);

    if (overrideUser1) {
      sqlCache.updateBySql(TournamentQuery.overrideMatchUser1, params);
    }
    else {
      sqlCache.updateBySql(TournamentQuery.overrideMatchUser2, params);
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

      TypeReference<List<TournamentFormulaField>> formulaFieldsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "tournamentFormulaFields",
        new JsonCollectionDeserializer(formulaFieldsRef, objectMapper));
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
