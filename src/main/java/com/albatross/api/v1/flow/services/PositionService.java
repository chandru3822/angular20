package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.queries.PositionQuery;
import com.albatross.api.v1.flow.queries.ProcessQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class PositionService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final CustomFieldService customFieldService;

  public List<Position> getPositionsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(PositionQuery.getAllForCompany, params, Position.class);
  }

  public List<Position> getSchedulablePositions() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);

    return sqlCache.queryBySql(PositionQuery.getSchedulablePositions, params, Position.class);
  }

  public List<Position> getPositionsForCompanyWithParent() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    return sqlCache.queryBySql(PositionQuery.getAllForCompanyWithParent, params, Position.class);
  }

  public Position getPosition(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", user.getCompanyId());
    return sqlCache
        .getBySql(PositionQuery.getOne, params, new PositionMapper<>(Position.class, om))
        .orElse(null);
  }

  public Position insertPosition(Position p) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgTypeId", p.getOrgTypeId());
    params.put("position", p.getPosition());
    params.put("schedulable", null != p.getSchedulable() ? p.getSchedulable() : false);
    params.put("useSlotSchedule", null != p.getUseSlotSchedule() ? p.getUseSlotSchedule() : false);
    params.put("scheduler", null != p.getScheduler() ? p.getScheduler() : false);
    params.put("contactOwner", null != p.getContactOwner() ? p.getContactOwner() : false);
    params.put("projectOwner", null != p.getProjectOwner() ? p.getProjectOwner() : false);
    params.put("smsOwner", null != p.getSmsOwner() ? p.getSmsOwner() : false);
    params.put(
        "availableToChildren",
        null != p.getAvailableToChildren() ? p.getAvailableToChildren() : false);
    params.put("createdById", user.trueUserId());
    Long positionId = sqlCache.updateBySqlReturningId(PositionQuery.insert, params, "id").longValue();

    for (CompanyFeature cf : p.getCompanyFeatures()) {
      for (FeatureAccessControl ac : cf.getAccessControl()) {
        if (ac.isEnabled()) {
          params.put("companyFeatureId", cf.getId());
          params.put("accessControlId", ac.getId());
          params.put("positionId", positionId);
          sqlCache.updateBySql(PositionQuery.insertPositionFeatureAccessControl, params);
        }
      }
    }

    return getPosition(positionId);
  }

  public Position updatePosition(Position p) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgTypeId", p.getOrgTypeId());
    params.put("position", p.getPosition());
    params.put("schedulable", null != p.getSchedulable() ? p.getSchedulable() : false);
    params.put("useSlotSchedule", null != p.getUseSlotSchedule() ? p.getUseSlotSchedule() : false);
    params.put("scheduler", null != p.getScheduler() ? p.getScheduler() : false);
    params.put("contactOwner", null != p.getContactOwner() ? p.getContactOwner() : false);
    params.put("projectOwner", null != p.getProjectOwner() ? p.getProjectOwner() : false);
    params.put("smsOwner", null != p.getSmsOwner() ? p.getSmsOwner() : false);
    params.put(
        "availableToChildren",
        null != p.getAvailableToChildren() ? p.getAvailableToChildren() : false);
    params.put("id", p.getId());
    params.put("modifiedById", user.trueUserId());
    sqlCache.updateBySql(PositionQuery.update, params);

    // i think these dirty checks are redundant now that i filtered the frontend but i am leaving
    // them in cuz it works and i dont want to update it and have to test it again
    for (CompanyFeature cf : p.getCompanyFeatures()) {
      if (cf.isDirty()) {
        for (FeatureAccessControl ac : cf.getAccessControl()) {
          if (ac.isDirty()) {
            if (null != ac.getId()) {
              params.put("enabled", ac.isEnabled());
              params.put("id", ac.getId());
              sqlCache.updateBySql(PositionQuery.updatePositionFeatureAccessControl, params);
            } else if (ac.isEnabled()) {
              params.put("companyFeatureId", cf.getId());
              params.put("accessControlId", ac.getAccessControlId());
              params.put("positionId", p.getId());
              sqlCache.updateBySql(PositionQuery.insertPositionFeatureAccessControl, params);
            }
          }
        }
      }
    }

    return getPosition(p.getId());
  }

  public Position clonePosition(Position p, Long clonePositionId) {
    User user = securityService.getCurrentUser();
    Position clonedPosition = getPosition(clonePositionId);

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgTypeId", clonedPosition.getOrgTypeId());
    params.put("position", p.getPosition());
    params.put("schedulable", null != clonedPosition.getSchedulable() ? clonedPosition.getSchedulable() : false);
    params.put("useSlotSchedule", null != clonedPosition.getUseSlotSchedule() ? clonedPosition.getUseSlotSchedule() : false);
    params.put("scheduler", null != clonedPosition.getScheduler() ? clonedPosition.getScheduler() : false);
    params.put("contactOwner", null != clonedPosition.getContactOwner() ? clonedPosition.getContactOwner() : false);
    params.put("projectOwner", null != clonedPosition.getProjectOwner() ? clonedPosition.getProjectOwner() : false);
    params.put("smsOwner", null != clonedPosition.getSmsOwner() ? clonedPosition.getSmsOwner() : false);
    params.put(
      "availableToChildren",
      null != clonedPosition.getAvailableToChildren() ? clonedPosition.getAvailableToChildren() : false);
    params.put("createdById", user.trueUserId());
    Long positionId = sqlCache.updateBySqlReturningId(PositionQuery.insert, params, "id").longValue();

    if (p.getCloneAccess() != null && p.getCloneAccess()) {
      for (CompanyFeature cf : clonedPosition.getCompanyFeatures()) {
        for (FeatureAccessControl ac : cf.getAccessControl()) {
          if (ac.isEnabled()) {
            params.clear();
            params.put("companyFeatureId", cf.getId());
            params.put("accessControlId", ac.getAccessControlId());
            params.put("positionId", positionId);
            sqlCache.updateBySql(PositionQuery.insertPositionFeatureAccessControl, params);
          }
        }
      }
    }

    if (p.getCloneOwnership() != null && p.getCloneOwnership()) {
      List<OwningPosition> owningPositions = getOwnerPositionsByPosition(clonePositionId);
      // Add the new position as an owner to the same process steps as the cloned position
      for (OwningPosition owningPosition: owningPositions) {
        params.clear();
        params.put("processStepProcessId", owningPosition.getProcessStepProcessId());
        params.put("positionId", positionId);
        params.put("createdById", user.trueUserId());
        sqlCache.updateBySql(ProcessQuery.insertOwningPosition, params);
      }
    }

    if (p.getCloneWhitelist() != null && p.getCloneWhitelist()) {
      List<WhiteListedPosition> whiteListedPositions = getWhiteListedPositionsByPosition(clonePositionId);
      for (WhiteListedPosition whiteListedPosition: whiteListedPositions) {
        params.clear();
        params.put("customFieldGroupAssignmentId", whiteListedPosition.getCustomFieldGroupAssignmentId());
        params.put("processStepId", whiteListedPosition.getProcessStepId());
        params.put("positionId", positionId);
        params.put("workQueueTypeId", whiteListedPosition.getWorkQueueTypeId());
        params.put("workQueueCategoryId", whiteListedPosition.getWorkQueueCategoryId());
        params.put("companyId", user.getCompanyId());
        params.put("whiteListTypeId", whiteListedPosition.getWhiteListTypeId());
        params.put("eventId", whiteListedPosition.getEventId());
        params.put("userId", user.trueUserId());
        sqlCache.updateBySql(PositionQuery.insertWhiteListPosition, params);
      }
    }

    if (p.getCloneSystemList() != null && p.getCloneSystemList()) {
      List<CustomField> customFields = customFieldService.getCustomFieldsByPositionId(clonePositionId);
      for (CustomField cf: customFields) {
        List<Long> systemListOptions = cf.getSystemListOptionIds();
        systemListOptions.add(positionId);

        try {
          customFieldService.saveField(cf);
        } catch (SQLException e) {
          log.error("POSITION: Error while cloning position system list", e);
        }
      }
    }

    return getPosition(positionId);
  }

  public void deletePosition(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());
    sqlCache.updateBySql(PositionQuery.delete, params);
  }

  private List<OwningPosition> getOwnerPositionsByPosition(Long positionId) {
    return sqlCache.queryBySql(
      ProcessQuery.getOwnerPositionsByPosition,
      ImmutableMap.of("positionId", positionId),
      OwningPosition.class);
  }

  private List<WhiteListedPosition> getWhiteListedPositionsByPosition(Long positionId) {
    User user = securityService.getCurrentUser();

    return sqlCache.query(
      PositionQuery.getWhiteListedPositionsByPosition,
      ImmutableMap.of("companyId", user.getCompanyId(), "positionId", positionId),
      WhiteListedPosition.class);
  }

  public static class PositionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public PositionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CompanyFeature>> companyFeaturesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "companyFeatures",
          new JsonCollectionDeserializer(companyFeaturesRef, objectMapper));
    }
  }
}
