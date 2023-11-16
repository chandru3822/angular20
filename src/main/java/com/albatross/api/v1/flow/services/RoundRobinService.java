package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.RoundRobinUserType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.PostalCode;
import com.albatross.api.v1.flow.model.roundRobin.RoundRobinAllocationUser;
import com.albatross.api.v1.flow.model.roundRobin.RoundRobin;
import com.albatross.api.v1.flow.model.roundRobin.RoundRobinUser;
import com.albatross.api.v1.flow.queries.RoundRobinQuery;
import com.albatross.api.v1.flow.queries.ProjectQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class RoundRobinService {

  private final SqlCache sqlCache;
  private final SqlArrayService sqlArrayService;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<RoundRobin> getRoundRobins(String searchQuery) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("searchQuery", searchQuery);

    return sqlCache.queryBySql(RoundRobinQuery.getRoundRobins, params, RoundRobin.class);
  }

  public List<RoundRobin> getRoundRobinsForUser() {
    User user = securityService.getCurrentUser();

    Boolean viewAll =
      securityService.userHasFeatureAccessLevel(
        user.getId(),
        user.getCompanyId(),
        user.getHighestCompanyId(),
        "CLOSER_AVAILABILITY",
        List.of("VIEW_ALL"));

    Boolean viewCustom = false;
    //only check view downline if they dont have view all
    if(!viewAll) {
      viewCustom =
        securityService.userHasFeatureAccessLevel(
          user.getId(),
          user.getCompanyId(),
          user.getHighestCompanyId(),
          "CLOSER_AVAILABILITY",
          List.of("VIEW_CUSTOM"));
    }

    //if !viewAll && !viewCustom then we assume they have view or else they couldn't be making this call
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());
    params.put("viewAll", viewAll);
    params.put("viewCustom", viewCustom);

    return sqlCache.queryBySql(RoundRobinQuery.getRoundRobinsForUser, params, RoundRobin.class);
  }

  public RoundRobin getRoundRobin(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(RoundRobinQuery.getRoundRobin, params, RoundRobin.class).orElse(null);
  }

  public List<RoundRobinAllocationUser> getScheduleToUsers(Long roundRobinId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinId);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    return sqlCache.queryBySql(RoundRobinQuery.getScheduleToUsers, params, RoundRobinAllocationUser.class);
  }

  public List<RoundRobinUser> getScheduleByUsers(Long roundRobinId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinId);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    return sqlCache.queryBySql(RoundRobinQuery.getScheduleByUsers, params, RoundRobinUser.class);
  }

  public List<PostalCode> getAssignedCodesForRoundRobin(Long roundRobinId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinId);

    return sqlCache.queryBySql(RoundRobinQuery.getAssignedCodesForRoundRobin, params, PostalCode.class);
  }

  public List<PostalCode> getAvailableCodesForRoundRobin(Long roundRobinId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinId);

    return sqlCache.queryBySql(RoundRobinQuery.getAvaialbleCodesForRoundRobin, params, PostalCode.class);
  }

  public List<RoundRobinAllocationUser> saveManualUserAllocations(
      Long roundRobinId, List<RoundRobinAllocationUser> allocationUsers) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());

    for (RoundRobinAllocationUser u : allocationUsers) {
      params.put("rruId", u.getRoundRobinUserId());
      params.put("manualAllocation", u.getManualAllocation());

      sqlCache.updateBySql(RoundRobinQuery.saveManualUserAllocation, params);
    }
    // if users get terminated then they are still in zones. archiving them here ensures that if an
    // allocation change is made it will also archive any terminated users
    archiveInactiveUsers(roundRobinId);

    return getScheduleToUsers(roundRobinId);
  }

  public void archiveInactiveUsers(Long roundRobinId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("roundRobinId", roundRobinId);

    sqlCache.updateBySql(RoundRobinQuery.archiveInactiveUsers, params);
  }

  public RoundRobin saveRoundRobin(RoundRobin roundRobin) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("roundRobinName", roundRobin.getRoundRobinName());
    params.put("companyTimezoneId", roundRobin.getCompanyTimezoneId());
    params.put("distributionTimeFrameDays", roundRobin.getDistributionTimeFrameDays());
    params.put("schedulableFutureDays", roundRobin.getSchedulableFutureDays());
    params.put("usesTotalLeadAllocation", roundRobin.getUsesTotalLeadAllocation());

    Long id;
    if (null != roundRobin.getId()) {
      id = roundRobin.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      sqlCache.updateBySql(RoundRobinQuery.updateRoundRobin, params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateBySqlReturningId(RoundRobinQuery.insertRoundRobin, params, "id").longValue();
    }

    return getRoundRobin(id);
  }

  public void deleteRoundRobin(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.updateBySql(RoundRobinQuery.deleteRoundRobin, params);
  }

  public RoundRobinUser insertUser(RoundRobinUser roundRobinUser, Long roundRobinUserTypeId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinUser.getRoundRobinId());
    params.put("userId", roundRobinUser.getUserId());
    params.put("createdById", user.trueUserId());
    params.put("companyTimezoneId", null);
    params.put("roundRobinUserTypeId", roundRobinUserTypeId);

    Long id = sqlCache.updateBySqlReturningId(RoundRobinQuery.insertRoundRobinUser, params, "id").longValue();

    return getRoundRobinUser(id);
  }

  public List<RoundRobinAllocationUser> insertAllocationUser(
      Long roundRobinId, RoundRobinUser roundRobinUser) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinUser.getRoundRobinId());
    params.put("userId", roundRobinUser.getUserId());
    params.put("createdById", user.trueUserId());
    params.put("companyTimezoneId", roundRobinUser.getCompanyTimezoneId());
    params.put("roundRobinUserTypeId", RoundRobinUserType.SCHEDULE_TO.id);

    sqlCache.updateBySql(RoundRobinQuery.insertRoundRobinUser, params);

    // if users get terminated then they are still in zones. archiving them here ensures that if a
    // new allocation user is added it will also archive any terminated users
    archiveInactiveUsers(roundRobinId);

    // adding an allocation user requires sending back the full allocation list instead of just the
    // one user
    return getScheduleToUsers(roundRobinId);
  }

  public RoundRobinUser updateAllocationUser(Long rruId, RoundRobinAllocationUser roundRobinUser) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("rruId", rruId);
    params.put("modifiedById", user.trueUserId());
    params.put("companyTimezoneId", roundRobinUser.getCompanyTimezoneId());

    sqlCache.updateBySql(RoundRobinQuery.updateRoundRobinUser, params);

    return getRoundRobinUser(rruId);
  }

  public void deleteUser(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.updateBySql(RoundRobinQuery.deleteRoundRobinUser, params);
  }

  public List<RoundRobinAllocationUser> deleteAllocationUser(
      Long roundRobinId, Long roundRobinUserId) {
    // delete the user like normal but return the adjusted allocation values
    deleteUser(roundRobinUserId);
    // if users get terminated then they are still in zones. archiving them here ensures that if an
    // allocation user is deleted it will also archive any terminated users
    archiveInactiveUsers(roundRobinId);

    return getScheduleToUsers(roundRobinId);
  }

  public RoundRobinUser getRoundRobinUser (Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(RoundRobinQuery.getRoundRobinUser, params, RoundRobinUser.class).orElse(null);
  }

  public ResponseEntity addCode(Long roundRobinId, PostalCode pc) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinId);
    params.put("createdById", user.trueUserId());
    params.put("id", pc.getId());

    //we no longer need to do all the checks. they can only assign existing postal codes to a round robin
    sqlCache.updateBySql(RoundRobinQuery.updatePostalCode, params);
    return ResponseEntity.ok(getPostalCode(pc.getId()));

  }

  public void deleteRoundRobinFromPostalCode(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.updateBySql(RoundRobinQuery.deleteRoundRobinFromPostalCode, params);
  }

  public List<User> getAvailableRoundRobinUsers(Long roundRobinId, Boolean loadSchedulers) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinId);
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("isSchedulingTool", true);
    params.put("loadSchedulers", loadSchedulers);

    return sqlCache.queryBySql(RoundRobinQuery.getAvailableRoundRobinUsers, params, User.class);
  }

  public RoundRobin getRoundRobinByPostalCode(String postalCode, Long projectId) {
    User user = securityService.getCurrentUser();
    Long companyId = user.getCompanyId();
    HashMap<String, Object> params = new HashMap<>();

    if (null != projectId) {
      // had to change this so that a parent looking at a child project could still see project tabs
      params.put("projectId", projectId);
      Optional<Long> overrideCompanyId =
          sqlCache.queryForObjectOptionalBySql(ProjectQuery.getCompanyId, params, Long.class);
      if (overrideCompanyId.isPresent()) {
        companyId = overrideCompanyId.get();
      } else {
        log.error("PCS: No Company ID found for project. {}", projectId);
        throw new ResponseStatusException(
            HttpStatus.NOT_FOUND, "No Company ID found for that project", new Exception());
      }
    }

    params.put("postalCode", postalCode);
    params.put("companyId", companyId);

    return sqlCache
        .getBySql(RoundRobinQuery.getRoundRobinByPostalCode, params, RoundRobin.class)
        .orElse(null);
  }

  public Boolean userCanSchedule(String postalCode) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCode", postalCode);
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());

    List<User> results = sqlCache.queryBySql(RoundRobinQuery.userCanSchedule, params, User.class);
    return results.size() > 0;
  }

  public Boolean userCanScheduleRemote() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());

    List<User> results = sqlCache.queryBySql(RoundRobinQuery.userCanScheduleRemote, params, User.class);
    return results.size() > 0;
  }

  public List<RoundRobinUser> getAllRoundRobinUsers(List<Integer> roundRobinIds) throws SQLException {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("roundRobinIds", sqlArrayService.createSqlArrayOfType("int", roundRobinIds));

    return sqlCache.queryBySql(
      RoundRobinQuery.getAllRoundRobinUsers,
        params,
        new RoundRobinUserMapper<>(RoundRobinUser.class, om));
  }

  public List<RoundRobinUser> getRoundRobinUsersByDownline(List<Integer> roundRobinIds) throws SQLException {
    User user = securityService.getCurrentUser();

    Boolean viewAll =
      securityService.userHasFeatureAccessLevel(
        user.getId(),
        user.getCompanyId(),
        user.getHighestCompanyId(),
        "CLOSER_AVAILABILITY",
        List.of("VIEW_ALL"));

    Boolean viewCustom = false;
    //only check view downline if they dont have view all
    if(!viewAll) {
      viewCustom =
        securityService.userHasFeatureAccessLevel(
          user.getId(),
          user.getCompanyId(),
          user.getHighestCompanyId(),
          "CLOSER_AVAILABILITY",
          List.of("VIEW_CUSTOM"));
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());
    params.put("viewAll", viewAll);
    params.put("viewCustom", viewCustom);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("roundRobinIds", sqlArrayService.createSqlArrayOfType("int", roundRobinIds));

    return sqlCache.queryBySql(
      RoundRobinQuery.getRoundRobinUsersByDownline,
        params,
        new RoundRobinUserMapper<>(RoundRobinUser.class, om));
  }

  public PostalCode getPostalCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
        .getBySql(RoundRobinQuery.getPostalCode, params, PostalCode.class)
        .orElse(null);
  }

  public static class RoundRobinMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public RoundRobinMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<PostalCode>> postalCodesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "postalCodes", new JsonCollectionDeserializer(postalCodesRef, objectMapper));

      TypeReference<List<RoundRobinUser>> scheduleToUsersRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "scheduleToUsers",
          new JsonCollectionDeserializer(scheduleToUsersRef, objectMapper));

      TypeReference<List<RoundRobinUser>> scheduleByUsersRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "scheduleByUsers",
          new JsonCollectionDeserializer(scheduleByUsersRef, objectMapper));
    }
  }

  public static class RoundRobinUserMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public RoundRobinUserMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<UserPosition>> userPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "userPositions",
          new JsonCollectionDeserializer(userPositionsRef, objectMapper));
    }
  }
}
