package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.PostalCodeZoneUserType;
import com.albatross.api.v1.flow.model.*;
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
public class PostalCodeService {

  private final SqlCache sqlCache;
  private final SqlArrayService sqlArrayService;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<PostalCodeZone> getZones(String searchQuery) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("searchQuery", searchQuery);

    return sqlCache.query("postalCode.getZones", params, PostalCodeZone.class);
  }

  public PostalCodeZone getZone(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.get("postalCode.getZone", params, PostalCodeZone.class).orElse(null);
  }

  public List<PostalCodeAllocationUser> getScheduleToUsers(Long zoneId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);

    return sqlCache.query("postalCode.getScheduleToUsers", params, PostalCodeAllocationUser.class);
  }

  public List<PostalCodeZoneUser> getScheduleByUsers(Long zoneId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);

    return sqlCache.query("postalCode.getScheduleByUsers", params, PostalCodeZoneUser.class);
  }

  public List<PostalCodeZonePostalCode> getCodesForZone(Long zoneId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);

    return sqlCache.query("postalCode.getCodesForZone", params, PostalCodeZonePostalCode.class);
  }

  public List<PostalCodeAllocationUser> saveManualUserAllocations(
      Long zoneId, List<PostalCodeAllocationUser> allocationUsers) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());

    for (PostalCodeAllocationUser u : allocationUsers) {
      params.put("pczuId", u.getPostalCodeZoneUserId());
      params.put("manualAllocation", u.getManualAllocation());

      sqlCache.update("postalCode.saveManualUserAllocation", params);
    }
    // if users get terminated then they are still in zones. archiving them here ensures that if an
    // allocation change is made it will also archive any terminated users
    archiveInactiveUsers(zoneId);

    return getScheduleToUsers(zoneId);
  }

  public void archiveInactiveUsers(Long zoneId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("zoneId", zoneId);

    sqlCache.update("postalCode.archiveInactiveUsers", params);
  }

  public PostalCodeZone saveZone(PostalCodeZone zone) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("zoneName", zone.getZoneName());
    params.put("companyTimezoneId", zone.getCompanyTimezoneId());
    params.put("distributionTimeFrameDays", zone.getDistributionTimeFrameDays());
    params.put("schedulableFutureDays", zone.getSchedulableFutureDays());

    Long id;
    if (null != zone.getId()) {
      id = zone.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      sqlCache.update("postalCode.updateZone", params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateReturningId("postalCode.insertZone", params, "id").longValue();
    }

    return getZone(id);
  }

  public void deleteZone(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("postalCode.deleteZone", params);
  }

  public PostalCodeZoneUser insertUser(PostalCodeZoneUser zoneUser, Long postalCodeZoneUserTypeId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCodeZoneId", zoneUser.getPostalCodeZoneId());
    params.put("userId", zoneUser.getUserId());
    params.put("createdById", user.trueUserId());
    params.put("companyTimezoneId", null);
    params.put("postalCodeZoneUserTypeId", postalCodeZoneUserTypeId);

    Long id = sqlCache.updateReturningId("postalCode.insertZoneUser", params, "id").longValue();

    return getZoneUser(id);
  }

  public List<PostalCodeAllocationUser> insertAllocationUser(
      Long zoneId, PostalCodeZoneUser zoneUser) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCodeZoneId", zoneUser.getPostalCodeZoneId());
    params.put("userId", zoneUser.getUserId());
    params.put("createdById", user.trueUserId());
    params.put("companyTimezoneId", zoneUser.getCompanyTimezoneId());
    params.put("postalCodeZoneUserTypeId", PostalCodeZoneUserType.SCHEDULE_TO.id);

    sqlCache.update("postalCode.insertZoneUser", params);

    // if users get terminated then they are still in zones. archiving them here ensures that if a
    // new allocation user is added it will also archive any terminated users
    archiveInactiveUsers(zoneId);

    // adding an allocation user requires sending back the full allocation list instead of just the
    // one user
    return getScheduleToUsers(zoneId);
  }

  public PostalCodeZoneUser updateAllocationUser(Long pczuId, PostalCodeAllocationUser zoneUser) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("pczuId", pczuId);
    params.put("modifiedById", user.trueUserId());
    params.put("companyTimezoneId", zoneUser.getCompanyTimezoneId());

    sqlCache.update("postalCode.updateZoneUser", params);

    return getZoneUser(pczuId);
  }

  public void deleteUser(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("postalCode.deleteZoneUser", params);
  }

  public List<PostalCodeAllocationUser> deleteAllocationUser(
      Long zoneId, Long postalCodeZoneUserId) {
    // delete the user like normal but return the adjusted allocation values
    deleteUser(postalCodeZoneUserId);
    // if users get terminated then they are still in zones. archiving them here ensures that if an
    // allocation user is deleted it will also archive any terminated users
    archiveInactiveUsers(zoneId);

    return getScheduleToUsers(zoneId);
  }

  public PostalCodeZoneUser getZoneUser(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.get("postalCode.getZoneUser", params, PostalCodeZoneUser.class).orElse(null);
  }

  public ResponseEntity addCode(PostalCodeZonePostalCode pc) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCodeZoneId", pc.getPostalCodeZoneId());
    params.put("postalCode", pc.getPostalCode());
    params.put("createdById", user.trueUserId());

    Optional<PostalCodeZonePostalCode> result =
        sqlCache.get("postalCode.checkForExisting", params, PostalCodeZonePostalCode.class);
    if (result.isPresent() && !result.get().getPostalCodeZoneArchived()) {
      HashMap<String, Object> errorObj = new HashMap<>();
      errorObj.put("message", "Error: Postal Code Already In Use");
      return ResponseEntity.badRequest().body(errorObj);
    } else if (result.isPresent() && result.get().getPostalCodeZoneArchived()) {
      // if the postal code zone has been deleted, then just update the record instead of adding a
      // new row
      // this feels like the wrong way. but i wanted to keep the unique constraint without archiving
      // all postal codes when a zone is archived
      params.put("id", result.get().getId());
      sqlCache.update("postalCode.updateZoneCode", params);

      return ResponseEntity.ok(getZonePostalCode(result.get().getId()));
    } else {
      Long id = sqlCache.updateReturningId("postalCode.addZoneCode", params, "id").longValue();
      return ResponseEntity.ok(getZonePostalCode(id));
    }
  }

  public void deleteCode(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("postalCode.deleteZoneCode", params);
  }

  public List<User> getAvailableZoneUsers(Long zoneId, Boolean loadSchedulers) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("isSchedulingTool", true);
    params.put("loadSchedulers", loadSchedulers);

    return sqlCache.query("postalCode.getAvailableZoneUsers", params, User.class);
  }

  public PostalCodeZone getZoneByPostalCode(String postalCode, Long projectId) {
    User user = securityService.getCurrentUser();
    Long companyId = user.getCompanyId();
    HashMap<String, Object> params = new HashMap<>();

    if (null != projectId) {
      // had to change this so that a parent looking at a child project could still see project tabs
      params.put("projectId", projectId);
      Optional<Long> overrideCompanyId =
          sqlCache.queryForObjectOptional("project.getCompanyId", params, Long.class);
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
        .get("postalCode.getZoneByPostalCode", params, PostalCodeZone.class)
        .orElse(null);
  }

  public Boolean userCanSchedule(String postalCode) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCode", postalCode);
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());

    List<User> results = sqlCache.query("postalCode.userCanSchedule", params, User.class);
    return results.size() > 0;
  }

  public Boolean userCanScheduleRemote() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());

    List<User> results = sqlCache.query("postalCode.userCanScheduleRemote", params, User.class);
    return results.size() > 0;
  }

  public List<PostalCodeZoneUser> getAllZoneUsers(List<Integer> zoneIds) throws SQLException {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("zoneIds", sqlArrayService.createSqlArrayOfType("int", zoneIds));

    return sqlCache.query(
        "postalCode.getAllZoneUsers",
        params,
        new PostalCodeZoneUserMapper<>(PostalCodeZoneUser.class, om));
  }

  public PostalCodeZonePostalCode getZonePostalCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
        .get("postalCode.getZoneCode", params, PostalCodeZonePostalCode.class)
        .orElse(null);
  }

  public static class PostalCodeZoneMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public PostalCodeZoneMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<PostalCodeZonePostalCode>> postalCodesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "postalCodes", new JsonCollectionDeserializer(postalCodesRef, objectMapper));

      TypeReference<List<PostalCodeZoneUser>> scheduleToUsersRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "scheduleToUsers",
          new JsonCollectionDeserializer(scheduleToUsersRef, objectMapper));

      TypeReference<List<PostalCodeZoneUser>> scheduleByUsersRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "scheduleByUsers",
          new JsonCollectionDeserializer(scheduleByUsersRef, objectMapper));
    }
  }

  public static class PostalCodeZoneUserMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public PostalCodeZoneUserMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
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
