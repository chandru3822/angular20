package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserOrgHierarchy;
import com.albatross.api.v1.flow.model.UserPosition;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserPositionService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<UserPosition> getUserPositions(Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);

    return sqlCache.query(
        "userPosition.getAll", params, new UserPositionMapper<>(UserPosition.class, om));
  }

  public List<UserPosition> getAllActiveUserPositions(Long userId) {
    // this returns a list of all active positions for a user regardless of company id
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    return sqlCache.query(
        "userPosition.getAllActive", params, new UserPositionMapper<>(UserPosition.class, om));
  }

  public UserPosition getOne(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
        .get("userPosition.getOne", params, new UserPositionMapper<>(UserPosition.class, om))
        .orElse(null);
  }

  public UserPosition getUserPrimaryPosition(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    return sqlCache
        .get(
            "userPosition.getUserPrimaryPosition",
            params,
            new UserPositionMapper<>(UserPosition.class, om))
        .orElse(null);
  }

  public void deleteUserPosition(Long userPositionId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("userPositionId", userPositionId);

    sqlCache.update("userPosition.delete", params);
  }

  public UserPosition saveUserPosition(UserPosition userPosition) {
    User user = securityService.getCurrentUser();
    Boolean primaryFlag =
        null != userPosition.getPrimaryFlag() ? userPosition.getPrimaryFlag() : false;
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", userPosition.getUserId());
    params.put("positionId", userPosition.getPositionId());
    params.put("orgId", userPosition.getOrgId());
    params.put("startDate", userPosition.getStartDate());
    params.put("endDate", userPosition.getEndDate());
    params.put("primaryFlag", primaryFlag);

    Long id;
    if (null != userPosition.getId()) {
      id = userPosition.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      sqlCache.update("userPosition.updateUserPosition", params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateReturningId("userPosition.insertUserPosition", params, "id").longValue();
      params.put("id", id);
    }

    if (primaryFlag) {
      // if setting a position to primary, need to remove all other primary positions
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
      bw.registerCustomEditor(
          List.class,
          "hierarchy",
          new JsonCollectionDeserializer(userOrgHierarchyRef, objectMapper));
    }
  }
}
