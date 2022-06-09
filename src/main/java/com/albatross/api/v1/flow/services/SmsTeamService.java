package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamOrg;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamPosition;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamUser;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SmsTeamService {
  private final SqlCache sqlCache;
  private final NamedParameterJdbcTemplate jdbc;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final MessagingService messagingService;

  public List<Owner> getUsers() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    return sqlCache.query(
        "project.getOwners",
        Map.of(
            "companyId", user.getCompanyId(),
            "isParent", isParent,
            "parentCompanyId", user.getHighestParentCompanyId()),
        Owner.class);
  }

  public List<SmsTeam> getTeams() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);

    return sqlCache.query("smsTeam.getAll", params, new SmsTeamMapper<>(SmsTeam.class, om));
  }

  public List<SmsTeam> getTeamsUsers() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);

    return sqlCache.query(
        "smsTeam.getAllTeamUsers", params, new SmsTeamMapper<>(SmsTeam.class, om));
  }

  public SmsTeam getTeamDetails(@NonNull Long teamId) {
    return sqlCache
        .get(
            "smsTeam.getDetails",
            Map.of("id", teamId),
            new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om))
        .orElse(null);
  }

  public SmsTeam saveTeam(SmsTeam st) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("teamName", st.getTeamName());

    Long id;
    if (st.getId() != null) {
      id = st.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      params.put("isDefault", st.getIsDefault());
      sqlCache.update("smsTeam.updateTeam", params);
    } else {
      params.put("createdById", user.trueUserId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("smsTeam.insertTeam", params, "id").longValue();
    }

    return getTeamDetails(id);
  }

  public void deleteTeam(Long smsTeamId) {
    // Get a list of Projects that have this team assigned to them
    List<Long> projectIds =
        sqlCache.query(
            "messaging.getProjectsBySmsTeam",
            Map.of("smsTeamId", smsTeamId),
            new SingleColumnRowMapper<>(Long.class));

    // Remote the team and team owners from any associated projects
    deleteTeamsAndOwnersFromProjects(smsTeamId, null, null, null);

    // For any Project that has no teams assigned, assign the default team
    messagingService.addDefaultTeam(projectIds);

    SmsTeam smsTeam = getTeamDetails(smsTeamId);
    User user = securityService.getCurrentUser();

    for (SmsTeamUser smsTeamUser : smsTeam.getUsers()) {
      deleteUser(smsTeamId, smsTeamUser.getId());
    }

    for (SmsTeamPosition smsTeamPosition : smsTeam.getPositions()) {
      deletePosition(smsTeamId, smsTeamPosition.getId());
    }

    for (SmsTeamOrg smsTeamOrg : smsTeam.getOrgs()) {
      deleteOrg(smsTeamId, smsTeamOrg.getId());
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", smsTeamId);
    params.put("modifiedById", user.trueUserId());
    sqlCache.update("smsTeam.deleteTeam", params);
  }

  public Optional<SmsTeamPosition> addPosition(Long teamId, Long positionId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", teamId);
    params.put("positionId", positionId);
    params.put("createdById", user.trueUserId());
    Long id = sqlCache.updateReturningId("smsTeam.addPosition", params, "id").longValue();
    return getTeamPosition(id);
  }

  public Optional<SmsTeamPosition> getTeamPosition(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("smsTeam.getPosition", params, SmsTeamPosition.class);
  }

  public void deletePosition(Long smsTeamId, Long positionId) {
    deleteTeamsAndOwnersFromProjects(smsTeamId, null, positionId, null);

    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("smsTeamId", smsTeamId);
    params.put("positionId", positionId);
    params.put("modifiedById", user.trueUserId());
    sqlCache.update("smsTeam.deletePosition", params);
  }

  public Optional<SmsTeamUser> addUser(Long teamId, Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", teamId);
    params.put("userId", userId);
    params.put("createdById", user.trueUserId());
    Long id = sqlCache.updateReturningId("smsTeam.addUser", params, "id").longValue();
    return getUser(id);
  }

  public Optional<SmsTeamUser> getUser(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("smsTeam.getUser", params, SmsTeamUser.class);
  }

  public void deleteUser(Long smsTeamId, Long teamUserId) {
    Optional<SmsTeamUser> smsTeamUser = getUser(teamUserId);
    smsTeamUser.ifPresent(
        teamUser -> deleteTeamsAndOwnersFromProjects(smsTeamId, null, null, teamUser.getUserId()));

    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("teamUserId", teamUserId);
    params.put("modifiedById", user.trueUserId());
    sqlCache.update("smsTeam.deleteUser", params);
  }

  // Used to remove a User when the User is no longer Active
  public void deleteUserByUserId(Long userId, Long orgId, Long positionId) {
    List<SmsTeam> smsTeams = getTeamsForUser(userId);
    for (SmsTeam smsTeam : smsTeams) {
      deleteTeamsAndOwnersFromProjects(smsTeam.getId(), orgId, positionId, userId);
    }

    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("modifiedById", user.trueUserId());
    sqlCache.update("smsTeam.deleteUserByUserId", params);
  }

  public Optional<SmsTeamOrg> addOrg(Long teamId, Long orgId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", teamId);
    params.put("orgId", orgId);
    params.put("createdById", user.trueUserId());
    Long id = sqlCache.updateReturningId("smsTeam.addOrg", params, "id").longValue();
    return getOrg(id);
  }

  public Optional<SmsTeamOrg> getOrg(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("smsTeam.getOrg", params, SmsTeamOrg.class);
  }

  public void deleteOrg(Long smsTeamId, Long orgId) {
    deleteTeamsAndOwnersFromProjects(smsTeamId, orgId, null, null);

    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("smsTeamId", smsTeamId);
    params.put("orgId", orgId);
    params.put("modifiedById", user.trueUserId());
    sqlCache.update("smsTeam.deleteOrg", params);
  }

  public List<SmsTeam> getTeamsForUser() {
    return getTeamsForUser(null);
  }

  public List<SmsTeam> getTeamsForUser(Long userId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    if (userId == null) {
      params.put("userId", user.getId());
    } else {
      params.put("userId", userId);
    }

    return sqlCache
        .query("smsTeam.getTeamsForUser", params, new SmsTeamMapper<>(SmsTeam.class, om))
        .stream()
        .filter(t -> !t.getUsers().isEmpty())
        .collect(Collectors.toList());
  }

  private void deleteTeamsAndOwnersFromProjects(
      Long smsTeamId, Long orgId, Long positionId, Long userId) {
    User user = securityService.getCurrentUser();
    String sqlQuery =
        "SELECT * FROM flow.remove_sms_team_project_owners(:smsTeamId::integer, :orgId::integer, :positionId::integer, :userId::integer, :modifiedById::integer)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("smsTeamId", smsTeamId);
    parameters.addValue("orgId", orgId);
    parameters.addValue("positionId", positionId);
    parameters.addValue("userId", userId);
    parameters.addValue("modifiedById", user.trueUserId());
    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public static class SmsTeamMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public SmsTeamMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<SmsTeamUser>> usersRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "users", new JsonCollectionDeserializer(usersRef, objectMapper));
      TypeReference<List<SmsTeamPosition>> positionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "positions", new JsonCollectionDeserializer(positionsRef, objectMapper));
      TypeReference<List<SmsTeamOrg>> orgsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "orgs", new JsonCollectionDeserializer(orgsRef, objectMapper));
    }
  }
}
