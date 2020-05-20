package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.PostalCode;
import com.albatross.api.v1.flow.model.PostalCodeZone;
import com.albatross.api.v1.flow.model.PostalCodeZoneUser;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class PostalCodeService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;


  public List<PostalCodeZone> getZones() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<PostalCodeZone> results = sqlCache.query("postalCode.getZones", params, PostalCodeZone.class);
    return results;
  }

  public PostalCodeZone getZone(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<PostalCodeZone> result = sqlCache.get("postalCode.getZone", params, new PostalCodeZoneMapper<>(PostalCodeZone.class, om) );
    return result.orElse(null);
  }

  public PostalCodeZone saveZone(PostalCodeZone zone) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("zoneName", zone.getZoneName());
    params.put("distributionTimeFrameDays", zone.getDistributionTimeFrameDays());

    Long id;
    if(null != zone.getId()) {
      id = zone.getId();
      params.put("id", id);
      params.put("modifiedById", user.getId());
      sqlCache.update("postalCode.updateZone", params);
    } else {
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("postalCode.insertZone", params, "id").longValue();
    }

    return getZone(id);
  }

  public void deleteZone(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("postalCode.deleteZone", params);
  }

  public PostalCodeZoneUser saveUser(PostalCodeZoneUser zoneUser) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCodeZoneId", zoneUser.getPostalCodeZoneId());
    params.put("allocation", zoneUser.getAllocation());
    params.put("userId", zoneUser.getUserId());

    Long id;
    if(null != zoneUser.getId()) {
      id = zoneUser.getId();
      params.put("modifiedById", user.getId());
      sqlCache.update("postalCode.updateZoneUser", params);

    } else {
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("postalCode.insertZoneUser", params, "id").longValue();
    }

    return getZoneUser(id);
  }

  public void saveAllocations(List<PostalCodeZoneUser> zoneUsers) {
    User user = securityService.getCurrentUser();

    for(PostalCodeZoneUser zoneUser: zoneUsers) {

      HashMap<String, Object> params = new HashMap<>();
      params.put("allocation", zoneUser.getAllocation());
      params.put("modifiedById", user.getId());
      params.put("id", zoneUser.getId());

      sqlCache.update("postalCode.updateZoneUser", params);
    }

  }

  public void deleteUser(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("postalCode.deleteZoneUser", params);
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
    params.put("createdById", user.getId());

    Optional<PostalCode> result = sqlCache.get("postalCode.checkForExisting", params, PostalCode.class);
    if(result.isPresent()) {
      HashMap<String, Object> errorObj = new HashMap<>();
      errorObj.put("message", "Error: Postal Code Already In Use");
      return ResponseEntity.badRequest().body(errorObj);
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
    params.put("modifiedById", user.getId());

    sqlCache.update("postalCode.deleteZoneCode", params);
  }

  public List<User> getZoneUsers(Long zoneId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("isSchedulingTool", true);

    List<User> results = sqlCache.query("postalCode.getZoneUsers", params, User.class);
    return results;
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

      TypeReference<List<PostalCodeZoneUser>> postalCodeZoneUsersRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "postalCodeZoneUsers",
        new JsonCollectionDeserializer(postalCodeZoneUsersRef, objectMapper));

    }
  }

}
