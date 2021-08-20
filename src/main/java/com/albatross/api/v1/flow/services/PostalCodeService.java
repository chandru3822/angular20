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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class PostalCodeService {


  private final SqlCache sqlCache;
  private final DataSource dataSource;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<PostalCodeZone> getZones(String searchQuery) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("searchQuery", searchQuery);

    List<PostalCodeZone> results = sqlCache.query("postalCode.getZones", params, PostalCodeZone.class);
    return results;
  }

  public PostalCodeZone getZone(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<PostalCodeZone> result = sqlCache.get("postalCode.getZone", params, PostalCodeZone.class);
    return result.orElse(null);
  }

  public List<PostalCodeAllocationUser> getScheduleToUsers(Long zoneId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);

    List<PostalCodeAllocationUser> results = sqlCache.query("postalCode.getScheduleToUsers", params, PostalCodeAllocationUser.class);
    return results;
  }

  public List<PostalCodeZoneUser> getScheduleByUsers(Long zoneId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);

    List<PostalCodeZoneUser> results = sqlCache.query("postalCode.getScheduleByUsers", params, PostalCodeZoneUser.class);
    return results;
  }

  public List<PostalCode> getCodesForZone(Long zoneId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);

    List<PostalCode> results = sqlCache.query("postalCode.getCodesForZone", params, PostalCode.class);
    return results;
  }

  public List<PostalCodeAllocationUser> saveManualUserAllocations(Long zoneId, List<PostalCodeAllocationUser> allocationUsers) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());

    for(PostalCodeAllocationUser u : allocationUsers) {
      params.put("pczuId", u.getPostalCodeZoneUserId());
      params.put("manualAllocation", u.getManualAllocation());

      sqlCache.update("postalCode.saveManualUserAllocation", params);
    }
    return getScheduleToUsers(zoneId);
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
    if(null != zone.getId()) {
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

  public List<PostalCodeAllocationUser> insertAllocationUser(Long zoneId, PostalCodeZoneUser zoneUser) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCodeZoneId", zoneUser.getPostalCodeZoneId());
    params.put("userId", zoneUser.getUserId());
    params.put("createdById", user.trueUserId());
    params.put("companyTimezoneId", zoneUser.getCompanyTimezoneId());
    params.put("postalCodeZoneUserTypeId", PostalCodeZoneUserType.SCHEDULE_TO.id);

    sqlCache.update("postalCode.insertZoneUser", params);

    //adding an allocation user requires sending back the full allocation list instead of just the one user
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

  public List<PostalCodeAllocationUser> deleteAllocationUser(Long zoneId, Long postalCodeZoneUserId) {
    //delete the user like normal but return the adjusted allocation values
    deleteUser(postalCodeZoneUserId);
    return getScheduleToUsers(zoneId);
  }

  public PostalCodeZoneUser getZoneUser(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<PostalCodeZoneUser> result = sqlCache.get("postalCode.getZoneUser", params, PostalCodeZoneUser.class);
    return result.orElse(null);
  }

  public ResponseEntity addCode(PostalCode pc) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCodeZoneId", pc.getPostalCodeZoneId());
    params.put("postalCode", pc.getPostalCode());
    params.put("createdById", user.trueUserId());

    Optional<PostalCode> result = sqlCache.get("postalCode.checkForExisting", params, PostalCode.class);
    if(result.isPresent() && !result.get().getPostalCodeZoneArchived()) {
      HashMap<String, Object> errorObj = new HashMap<>();
      errorObj.put("message", "Error: Postal Code Already In Use");
      return ResponseEntity.badRequest().body(errorObj);
    } else if (result.isPresent() && result.get().getPostalCodeZoneArchived()) {
      //if the postal code zone has been deleted, then just update the record instead of adding a new row
      //this feels like the wrong way. but i wanted to keep the unique constraint without archiving all postal codes when a zone is archived
      params.put("id", result.get().getId());
      sqlCache.update("postalCode.updateZoneCode", params);

      return ResponseEntity.ok(getZonePostalCode(result.get().getId()));
    } else {
      Long id = sqlCache.updateReturningId("postalCode.addZoneCode", params, "id").longValue();
      return ResponseEntity.ok(getZonePostalCode(id));
    }

//    try {
//      Long id = sqlCache.updateReturningId("postalCode.addZoneCode", params, "id").longValue();
//      return ResponseEntity.ok(getZonePostalCode(id));
//    } catch (Error ex) {
//      HashMap<String, Object> errorObj = new HashMap<>();
//      errorObj.put("msg", ex.getMessage());
//      return ResponseEntity.badRequest().body(errorObj);
//    }

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

    List<User> results = sqlCache.query("postalCode.getAvailableZoneUsers", params, User.class);
    return results;
  }

  public PostalCodeZone getZoneByPostalCode(String postalCode, Long projectId) {
    User user = securityService.getCurrentUser();
    Long companyId = user.getCompanyId();
    HashMap<String, Object> params = new HashMap<>();

    if(null != projectId) {
      //had to change this so that a parent looking at a child project could still see project tabs
      params.put("projectId", projectId);
      Optional<Long> overrideCompanyId = sqlCache.queryForObjectOptional("project.getCompanyId", params, Long.class);
      if(overrideCompanyId.isPresent()) {
        companyId = overrideCompanyId.get();
      } else {
        log.info("PCS: No Company ID found for project. {}", projectId);
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No Company ID found for that project", new Exception());
      }
    }

    params.put("postalCode", postalCode);
    params.put("companyId", companyId);

    Optional<PostalCodeZone> result = sqlCache.get("postalCode.getZoneByPostalCode", params, PostalCodeZone.class);
    return result.orElse(null);
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

  public List<User> getAllZoneUsers(List<Integer> zoneIds) throws SQLException {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("zoneIds", createSqlArrayOfType("int", zoneIds));

    List<User> results = sqlCache.query("postalCode.getAllZoneUsers", params, new UserService.UserMapper<>(User.class, om));
    return results;
  }

  private Array createSqlArrayOfType(String typeName, List<?> array) throws SQLException {
    if (array != null && !array.isEmpty()) {
      try (Connection connection = dataSource.getConnection()) {
        return connection.createArrayOf(typeName, array.toArray());
      }
    }
    return null;
  }

  public PostalCode getZonePostalCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<PostalCode> result = sqlCache.get("postalCode.getZoneCode", params, PostalCode.class);
    return result.orElse(null);
  }

  public static class PostalCodeZoneMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public PostalCodeZoneMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<PostalCode>> postalCodesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "postalCodes",
        new JsonCollectionDeserializer(postalCodesRef, objectMapper));

      TypeReference<List<PostalCodeZoneUser>> scheduleToUsersRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "scheduleToUsers",
        new JsonCollectionDeserializer(scheduleToUsersRef, objectMapper));

      TypeReference<List<PostalCodeZoneUser>> scheduleByUsersRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "scheduleByUsers",
        new JsonCollectionDeserializer(scheduleByUsersRef, objectMapper));

    }
  }

}
