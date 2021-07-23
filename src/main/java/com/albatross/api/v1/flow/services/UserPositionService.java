package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserOrgHierarchy;
import com.albatross.api.v1.flow.model.UserPosition;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
public class UserPositionService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<UserPosition> getUserPositions(Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);

    List<UserPosition> results = sqlCache.query("userPosition.getAll", params, new UserPositionMapper<>(UserPosition.class, om));

    return results;
  }

  public List<UserPosition> getAllActiveUserPositions(Long userId) {
    //this returns a list of all active positions for a user regardless of company id
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    List<UserPosition> results = sqlCache.query("userPosition.getAllActive", params, new UserPositionMapper<>(UserPosition.class, om));

    return results;
  }

  public UserPosition getOne(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<UserPosition> result = sqlCache.get("userPosition.getOne", params, new UserPositionMapper<>(UserPosition.class, om));

    return result.orElse(null);
  }

  public UserPosition getUserPrimaryPosition(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    Optional<UserPosition> result = sqlCache.get("userPosition.getUserPrimaryPosition", params, new UserPositionMapper<>(UserPosition.class, om));

    return result.orElse(null);
  }

  public void deleteUserPosition(Long userPositionId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("userPositionId", userPositionId);

    sqlCache.update("userPosition.delete", params);

  }

  public UserPosition saveUserPosition(UserPosition userPosition) {
    User user = securityService.getCurrentUser();
    Boolean primaryFlag = null != userPosition.getPrimaryFlag() ? userPosition.getPrimaryFlag() : false;
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", userPosition.getUserId());
    params.put("positionId", userPosition.getPositionId());
    params.put("orgId", userPosition.getOrgId());
    params.put("startDate", userPosition.getStartDate());
    params.put("endDate", userPosition.getEndDate());
    params.put("primaryFlag", primaryFlag);

    Long id;
    if(null != userPosition.getId()) {
      id = userPosition.getId();
      params.put("id", id);
      params.put("modifiedById", user.getId());
      sqlCache.update("userPosition.updateUserPosition", params);
    } else {
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("userPosition.insertUserPosition", params, "id").longValue();
      params.put("id", id);
    }

    if(primaryFlag) {
      //if setting a position to primary, need to remove all other primary positions
      sqlCache.update("userPosition.resetPrimaryFlags", params);
    }

    return getOne(id);
  }

  public static class UserPositionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public UserPositionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<UserOrgHierarchy>> userOrgHierarchyRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "hierarchy",
          new JsonCollectionDeserializer(userOrgHierarchyRef, objectMapper));
    }
  }

}
