package com.albatross.api.v1.flow.services;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.BeanWrapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ActiveUserPosition;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserOrgHierarchy;
import com.albatross.api.v1.flow.model.UserPosition;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.queries.UserPositionQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserPositionService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final SmsTeamService smsTeamService;
  private final ObjectMapper om;

  public List<UserPosition> getUserPositions(Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);

    return sqlCache.queryBySql(
      UserPositionQuery.getAll, params, new UserPositionMapper<>(UserPosition.class, om));
  }

  public List<Org> getAvailableSalesOrgs(Long positionId, Long orgId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("positionId", positionId);
    params.put("orgId", orgId);

    return sqlCache.queryBySql(
      UserPositionQuery.getAvailableSalesOrgs, params, Org.class);
  }

  public List<Long> getUserPositionIdsForOrgPosition(Long positionId, Long orgId){
      HashMap<String, Object> params = new HashMap<>();
      params.put("positionId", positionId);
      params.put("orgId", orgId);

      return sqlCache.queryBySql(
              UserPositionQuery.getUserPositionIdsForOrgPosition, params, new SingleColumnRowMapper<>(Long.class)
      );
  }

  public List<UserPosition> getAllActiveUserPositions(Long userId) {
    // this returns a list of all active positions for a user regardless of company id
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    return sqlCache.queryBySql(
      UserPositionQuery.getAllActive, params, new UserPositionMapper<>(UserPosition.class, om));
  }
  public List<Long> getAllActiveUserPositionIds(User user) {
    List<UserPosition> userPositions = user.getUserPositions();
    return null != userPositions && userPositions.size() > 0 ? userPositions.stream()
      .map(UserPosition::getPositionId)
      .collect(Collectors.toList()) : null;
  }

  public UserPosition getOne(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
        .getBySql(UserPositionQuery.getOne, params, new UserPositionMapper<>(UserPosition.class, om))
        .orElse(null);
  }

  public UserPosition getUserPrimaryPosition(Long userId, Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", companyId);

    return sqlCache
        .getBySql(
          UserPositionQuery.getUserPrimaryPosition,
            params,
            new UserPositionMapper<>(UserPosition.class, om))
        .orElse(null);
  }
    public List<UserPosition> getUsersWithSmartlistAccess(){
        Map<String, Object> params = Map.of("companyId", securityService.getCurrentUser().getCompanyId());
        return sqlCache.queryBySql(UserPositionQuery.getSmartlistUsers, params, new UserPositionService.UserPositionMapper<>(UserPosition.class, om));
    }

  public List<UserPosition> getPrimaryUserPositions() {
    Map<String, Object> params = Map.of("companyId", securityService.getCurrentUser().getCompanyId());
    return sqlCache.queryBySql(UserPositionQuery.getPrimaryUserPositions, params, new UserPositionMapper<>(UserPosition.class, om));
  }

  public void deleteUserPosition(Long userPositionId) {
    User user = securityService.getCurrentUser();

    UserPosition positionToBeDeleted = getOne(userPositionId);
    if (positionToBeDeleted.getPrimaryFlag()) {
      // Find all SMS Teams that use this position or org, then delete the User from all these teams
      smsTeamService.deleteUserByUserId(positionToBeDeleted.getUserId(), positionToBeDeleted.getOrgId(), positionToBeDeleted.getPositionId());
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("userPositionId", userPositionId);

    sqlCache.updateBySql(UserPositionQuery.delete, params);
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
    params.put("salesOrgId", userPosition.getSalesOrgId());
    params.put("startDate", userPosition.getStartDate());
    params.put("endDate", userPosition.getEndDate());
    params.put("primaryFlag", primaryFlag);

    UserPosition formerPrimaryPosition =
      sqlCache
      .getBySql(
        UserPositionQuery.getPrimaryPosition,
        params,
        new UserPositionMapper<>(UserPosition.class, om))
      .orElse(null);

    Long id;
    if (null != userPosition.getId()) {
      id = userPosition.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      sqlCache.updateBySql(UserPositionQuery.updateUserPosition, params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateBySqlReturningId(UserPositionQuery.insertUserPosition, params, "id").longValue();
      params.put("id", id);
    }

    if (primaryFlag) {
      // If there was an existing Primary that is being replaced,  remove User from any SMS conversations
      if (formerPrimaryPosition != null && formerPrimaryPosition.getId() != id) {
        // Find all SMS Teams that use this position or org, then delete the User from all these teams
        smsTeamService.deleteUserByUserId(userPosition.getUserId(), formerPrimaryPosition.getOrgId(), formerPrimaryPosition.getPositionId());
      }

      // if setting a position to primary, need to remove all other primary positions
      sqlCache.updateBySql(UserPositionQuery.resetPrimaryFlags, params);
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

      TypeReference<List<Long>> partnerIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, new JsonCollectionDeserializer(partnerIdsRef, objectMapper));
    }
  }

	/**
	 * @param positionId
	 * @param searchQuery
	 * @param pageable
	 * @return
	 */
	public Page<ActiveUserPosition> searchActiveUser(Integer positionId, String searchQuery, Pageable pageable) {
		List<ActiveUserPosition> activeUserList;
		long activeUserCount;
		try {
			Map<String, Object> params = Map.of("positionId", positionId, "query", searchQuery, "limit",
					pageable.getPageSize(), "offset", pageable.getOffset());
			String activeUserListJson = sqlCache.queryForObjectBySql(UserPositionQuery.searchPositionUser, params, String.class);
			activeUserList = om.readValue(activeUserListJson, new TypeReference<>() { });
			activeUserCount = sqlCache.queryForObjectBySql(UserPositionQuery.countPositionUser, params, Long.class);
			return new PageImpl<>(activeUserList, pageable, activeUserCount);
		} catch (Exception ex) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Could not fetch or parse user positions.", ex);
		}
	}
}
