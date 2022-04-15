package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.beans.BeanWrapper;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class WorkQueueService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final SmartlistService smartlistService;
  private final WorkQueueTypeService workQueueTypeService;
  private final SqlCacheRO sqlCacheRO;

  public List<WorkQueue> getWorkQueues(
      Long workQueueCategoryId,
      Long userId,
      Boolean unassigned,
      Boolean filterFutureFollowUps,
      Boolean filterFutureEvents) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueCategoryId", workQueueCategoryId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);
    params.put("filterFutureFollowUps", null != filterFutureFollowUps && filterFutureFollowUps);
    params.put("filterFutureEvents", null != filterFutureEvents && filterFutureEvents);
    params.put("unassigned", null != unassigned && unassigned);

    return sqlCache.query("workQueue.getWorkQueues", params, WorkQueue.class);
  }

  public SmartlistResult getWorkQueueDetails(
      Long workQueueTypeId,
      Long smartlistId,
      Long userId,
      Boolean unassigned,
      String timezone,
      Pageable pageable,
      List<Long> installationCrewIds) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueTypeId", workQueueTypeId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);
    params.put("unassigned", null == unassigned ? false : unassigned);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    Optional<WorkQueueType> workQueueType = workQueueTypeService.getType(workQueueTypeId);
    Smartlist smartlist = smartlistService.getSmartlist(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }
    log.debug("SMARTLIST: Running smartlist ID: " + smartlistId);
    List<SmartlistFieldAssignment> fields = smartlistService.getAssignedFields(smartlistId);

    fields = smartlistService.prettifyFieldNames(fields);

      String query = null;
      if ((workQueueType.isPresent() && !workQueueType.get().getUseEventData()) || (null != installationCrewIds && !installationCrewIds.isEmpty())) {
          // if the work queue type is not for event data OR it is for install crews, then keep doing
          // the same thing
          query = smartlistService.buildSql(smartlist, fields, timezone, installationCrewIds, false);
      } else {
          // this should only be called for wqt using event data
          query = smartlistService.buildWorkQueueSql(smartlist, fields, true, timezone);

          // add default fields to fields list
          var defaultFields = smartlistService.getEventWorkqueueDefaultFields(false);

          defaultFields.addAll(fields);
          fields = defaultFields;
      }
    List<Map<String, Object>> results = sqlCacheRO.queryBySql(query, null, new ColumnMapRowMapper());

    List<Map<String, Object>> randasResults = new ArrayList<>();

    for (Map<String, Object> result : results) {

      Map<String, Object> newResult = new HashMap<>();

      for (Map.Entry<String, Object> entry : result.entrySet()) {
        if (result.get(entry.getKey()) != null) {
          if (Objects.equals(entry.getValue().getClass(), PGobject.class)) {
            newResult.put(entry.getKey(), ((PGobject) entry.getValue()).getValue());
          } else {
            newResult.put(entry.getKey(), entry.getValue());
          }
        } else {
          newResult.put(entry.getKey(), entry.getValue());
        }
      }

      randasResults.add(newResult);
    }

    return new SmartlistResult(fields, randasResults);
  }

    public String buildSql(Long smartlistId, Boolean useEventData) {
        Smartlist smartlist = smartlistService.getSmartlist(smartlistId);
        if (smartlist == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
        }

        log.debug("SMARTLIST: Running smartlist ID: " + smartlistId);
        List<SmartlistFieldAssignment> fields = smartlistService.getAssignedFields(smartlistId);
        fields = smartlistService.prettifyFieldNames(fields);
        String query;
        if (useEventData) {
            query = smartlistService.buildWorkQueueSql(smartlist, fields, useEventData, null);

            // add default fields to fields list
            var defaultFields = smartlistService.getEventWorkqueueDefaultFields(false);
            defaultFields.addAll(fields);
            fields = defaultFields;
        } else {
            query = smartlistService.buildSql(smartlist, fields);
        }
        return query;
    }

  public List<WorkQueueOwner> getWorkQueueOwners() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());

    return sqlCache.query("workQueue.getWorkQueueOwners", params, WorkQueueOwner.class);
  }

  public static class WorkQueueDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public WorkQueueDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<OwningPosition>> owningPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "owningPositions",
          new JsonCollectionDeserializer(owningPositionsRef, objectMapper));

      TypeReference<List<ProjectProcessStep>> activeProcessStepsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "activeProcessSteps",
          new JsonCollectionDeserializer(activeProcessStepsRef, objectMapper));

      TypeReference<List<Note>> notesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "notes", new JsonCollectionDeserializer(notesRef, objectMapper));
    }
  }
}
