package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.WhiteListType;
import com.albatross.api.v1.flow.model.DurationType;
import com.albatross.api.v1.flow.model.FieldInUse;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.WhiteListedPosition;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepWorkQueueType;
import com.albatross.api.v1.flow.model.workQueue.*;
import com.albatross.api.v1.flow.queries.WorkQueueTypeQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@PreAuthorize("hasFeatureAccess('WORK_QUEUE')")
@RequiredArgsConstructor
public class WorkQueueTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<WorkQueueType> getWorkQueueTypes(Boolean sortByName) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());
    params.put("orderByName", null != sortByName ? sortByName : false);
    String orderBy =
        Boolean.TRUE.equals(sortByName)
            ? "order by wqt.work_queue_type"
            : "order by wqc.display_order, wqt.display_order, wqt.work_queue_type";

    String sql = WorkQueueTypeQuery.getTypesForCompany;
    sql += orderBy;
    return sqlCache.queryBySql(sql, params, WorkQueueType.class);
  }

  public String getItemsUsingWorkQueueType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("wqtId", id);
    String results = sqlCache.queryForObjectBySql(WorkQueueTypeQuery.getItemsUsingType, params, String.class);
    return results;
  }

  public List<DurationType> getDurationTypes() {
    return sqlCache.queryBySql(
      WorkQueueTypeQuery.getDurationTypes, Collections.emptyMap(), DurationType.class);
  }

  public Optional<WorkQueueType> getType(Long id) {
    return sqlCache.getBySql(
      WorkQueueTypeQuery.getType,
        ImmutableMap.of("id", id),
        new WorkQueueTypeMapper<>(WorkQueueType.class, om));
  }

  public void saveHiddenAndWhiteList(WorkQueueType workQueueType, Boolean savePositions) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("hidden", workQueueType.getHidden());
    params.put("wqtId", workQueueType.getId());
    params.put("whiteListTypeId", WhiteListType.WORK_QUEUE_TYPE_HIDDEN.id);

    sqlCache.updateBySql(WorkQueueTypeQuery.saveHidden, params);

    if (!workQueueType.getHidden()) {
      // if ps is not readonly archive any white listed positions for it
      sqlCache.updateBySql(WorkQueueTypeQuery.archiveWhiteListPositions, params);
    } else if (null != savePositions && savePositions) {
      // if field IS read_only archive any white listed positions no longer in the body sent in
      List<WhiteListedPosition> positionsToUse = workQueueType.getHiddenWhiteListedPositions();
      List<Long> positionIdsUsed = workQueueType.getHiddenWhiteListedPositions().stream()
                                              .map(WhiteListedPosition::getPositionId)
                                              .collect(Collectors.toList());
      params.put("positionIdsUsed", positionIdsUsed);
      if (positionIdsUsed.size() > 0) {
        sqlCache.updateBySql(WorkQueueTypeQuery.archiveWhiteListPositionsNoLongerUsed, params);
      } else {
        // this means they removed ALL white listed positions
        sqlCache.updateBySql(WorkQueueTypeQuery.archiveWhiteListPositions, params);
      }

      for (WhiteListedPosition wlp : positionsToUse) {
        params.put("positionId", wlp.getPositionId());
        // this insert checks if there is already a non-archived row with the same values
        sqlCache.updateBySql(WorkQueueTypeQuery.insertWhiteListPosition, params);
      }
    }
  }

  public ResponseEntity<List<FieldInUse>> deleteType(Long typeId) {
    User user = securityService.getCurrentUser();

    List<FieldInUse> fields = getProcessStepsUsingWqt(typeId);
    if (!fields.isEmpty()) {
      return ResponseEntity.badRequest().body(fields);
    } else {
      sqlCache.updateBySql(
        WorkQueueTypeQuery.deleteType,
        ImmutableMap.of("id", typeId, "modifiedById", user.trueUserId()));
      return ResponseEntity.ok().build();
    }
  }

  public List<FieldInUse> getProcessStepsUsingWqt(Long wqtId) {
    //this actually returns process steps and events using the wqtId
    HashMap<String, Object> params = new HashMap<>();
    params.put("wqtId", wqtId);
    List<FieldInUse> fieldsInUse = sqlCache.queryBySql(WorkQueueTypeQuery.getProcessStepsUsingWqt, params, FieldInUse.class);
    return fieldsInUse;
  }

  public Optional<WorkQueueType> updateType(WorkQueueType type) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", type.getId());
    params.put("modifiedById", user.trueUserId());
    params.put("workQueueCategoryId", type.getWorkQueueCategoryId());
    params.put("displayOrder", type.getDisplayOrder());
    params.put("workQueueType", type.getWorkQueueType());
    params.put("useEventData", null != type.getUseEventData() ? type.getUseEventData() : false);
    params.put("shortWindow", type.getShortWindow());
    params.put("shortWindowDurationTypeId", type.getShortWindowDurationTypeId());
    params.put("longWindow", type.getLongWindow());
    params.put("longWindowDurationTypeId", type.getLongWindowDurationTypeId());
    params.put("expectedCycle", type.getExpectedCycle());
    params.put("expectedCycleDurationTypeId", type.getExpectedCycleDurationTypeId());
    params.put(
        "inverseExpectation",
        null != type.getInverseExpectation() ? type.getInverseExpectation() : false);
    params.put("expectedTarget", type.getExpectedTarget());
    params.put("schedule", null != type.getSchedule() ? type.getSchedule().toString() : null);
    sqlCache.updateBySql(WorkQueueTypeQuery.updateType, params);

    return getType(type.getId());
  }

  public void updateTypeDisplayOrders(List<WorkQueueType> types) {
    for (WorkQueueType type : types) {
      // save each display_order (i guess i can just call the full update - will do the same thing)
      updateType(type);
    }
  }

  public Optional<WorkQueueType> insertType(WorkQueueType type) {
    Boolean useEventData = null != type.getUseEventData() ? type.getUseEventData() : false;
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueType", type.getWorkQueueType());
    params.put("useEventData", useEventData);
    params.put("createdById", user.trueUserId());
    params.put("workQueueCategoryId", type.getWorkQueueCategoryId());
    params.put("companyId", user.getCompanyId());
    Long id = sqlCache.updateBySqlReturningId(WorkQueueTypeQuery.insertType, params, "id").longValue();

    // any time a work queue type is created we need to create a smartlist placeholder for any
    // custom fields in the dropdown
    params.put("workQueueTypeId", id);
    // this is the root object type, then we combine it with company id to get the
    // company_object_type_id
    params.put("objectTypeId", useEventData ? ObjectType.EVENT.id : ObjectType.PROCESS_STEP.id);
    sqlCache.updateBySql(WorkQueueTypeQuery.addSmartlist, params);

    return getType(id);
  }

  public void deleteProcessStepWorkQueueType(Long id) {
    User currentUser = securityService.getCurrentUser();

    //this was updated to also delete the psWqt - process step statuses and project statuses so that a delete-readd doesn't bring back values that it shouldnt
    sqlCache.updateBySql(
      WorkQueueTypeQuery.deleteProcessStepWorkQueueType,
        ImmutableMap.of("id", id, "modifiedById", currentUser.trueUserId()));

    callConfigChangeFunction(id, null);
  }

  public Optional<ProcessStepWorkQueueType> getProcessStepWorkQueueType(Long id) {

    return sqlCache.getBySql(
      WorkQueueTypeQuery.getProcessStepWorkQueueType,
        ImmutableMap.of("id", id),
        new ProcessStepWorkQueueTypeMapper<>(ProcessStepWorkQueueType.class, om));
  }

  public Optional<ProcessStepWorkQueueType> insertProcessStepWorkQueueType(
      ProcessStepWorkQueueType wqt) {
    User currentUser = securityService.getCurrentUser();

    Long id =
        sqlCache
            .updateBySqlReturningId(
              WorkQueueTypeQuery.insertProcessStepWorkQueueType,
                ImmutableMap.of(
                    "createdById",
                    currentUser.trueUserId(),
                    "workQueueTypeId",
                    wqt.getWorkQueueTypeId(),
                    "processStepId",
                    wqt.getProcessStepId()),
                "id")
            .longValue();

    // handle pst on new wqt
    wqt.setId(id);
    saveProjectStatusTypesToWorkQueueType(wqt, null);
    saveProcessStepStatusTypesToWorkQueueType(wqt, null);

    callConfigChangeFunction(wqt.getId(), null);

    return getProcessStepWorkQueueType(id);
  }

  public List<WorkQueueType> getAvailableWorkQueueTypesForStep(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());
    params.put("id", id);

    return sqlCache.queryBySql(
      WorkQueueTypeQuery.getAvailableWorkQueueTypesForStep, params, WorkQueueType.class);
  }

  public List<WorkQueueTypeProjectStatus> saveProjectStatusTypesToWorkQueueType(
      ProcessStepWorkQueueType processStepWorkQueueType,
      ProcessStepEventWorkQueueType processStepEventWorkQueueType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    String insertSql = WorkQueueTypeQuery.insertProjectStatusTypeForProcessStep;
    String updateSql = WorkQueueTypeQuery.updateProjectStatusTypeForProcessStep;
    if (null != processStepWorkQueueType) {
      params.put("processStepWorkQueueTypeId", processStepWorkQueueType.getId());
    } else {
      params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueType.getId());
      insertSql = WorkQueueTypeQuery.insertProjectStatusTypeForEvent;
      updateSql = WorkQueueTypeQuery.updateProjectStatusTypeForEvent;
    }
    params.put("userId", currentUser.trueUserId());

    List<WorkQueueTypeProjectStatus> statuses =
        null != processStepWorkQueueType
            ? processStepWorkQueueType.getProjectStatuses()
            : processStepEventWorkQueueType.getProjectStatuses();
    for (WorkQueueTypeProjectStatus ps : statuses) {
      if (null != ps.getId() && ps.getArchived()) {
        params.put("archived", ps.getArchived());
        params.put("id", ps.getId());
        sqlCache.updateBySql(updateSql, params);
      } else if (null == ps.getId() && !ps.getArchived()) {
        params.put("companyProjectStatusTypeId", ps.getCompanyProjectStatusTypeId());
        params.put("projectStatusTypeId", ps.getIsRoot() ? ps.getProjectStatusTypeId() : null);
        sqlCache.updateBySql(insertSql, params);
      }
    }

    if (null != processStepWorkQueueType) {
      return getProjectStatusTypesForWorkQueueType(processStepWorkQueueType.getId(), null);
    } else {
      return getProjectStatusTypesForWorkQueueType(null, processStepEventWorkQueueType.getId());
    }
  }

  public void callConfigChangeFunction(Long psWqtId, Long pseWqtId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("createdById", currentUser.trueUserId());
    params.put("psWqtId", psWqtId);
    params.put("pseWqtId", pseWqtId);

    if (null != psWqtId) {
      sqlCache.queryForObjectBySql(WorkQueueTypeQuery.callPsConfigChangeFunction, params, String.class);
    } else {
      sqlCache.queryForObjectBySql(WorkQueueTypeQuery.callEventConfigChangeFunction, params, String.class);
    }
  }

  public List<WorkQueueTypeProcessStepStatus> saveProcessStepStatusTypesToWorkQueueType(
      ProcessStepWorkQueueType processStepWorkQueueType,
      ProcessStepEventWorkQueueType processStepEventWorkQueueType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    String insertSql = WorkQueueTypeQuery.insertProcessStepStatusTypeForProcessStep;
    String updateSql = WorkQueueTypeQuery.updateProcessStepStatusTypeForProcessStep;
    if (null != processStepWorkQueueType) {
      params.put("processStepWorkQueueTypeId", processStepWorkQueueType.getId());
    } else {
      params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueType.getId());
      insertSql = WorkQueueTypeQuery.insertProcessStepStatusTypeForEvent;
      updateSql = WorkQueueTypeQuery.updateProcessStepStatusTypeForEvent;
    }
    params.put("userId", currentUser.trueUserId());

    List<WorkQueueTypeProcessStepStatus> statuses =
        null != processStepWorkQueueType
            ? processStepWorkQueueType.getProcessStepStatuses()
            : processStepEventWorkQueueType.getProcessStepStatuses();
    for (WorkQueueTypeProcessStepStatus ps : statuses) {
      if (null != ps.getId() && ps.getArchived()) {
        params.put("archived", ps.getArchived());
        params.put("id", ps.getId());
        sqlCache.updateBySql(updateSql, params);
      } else if (null == ps.getId() && !ps.getArchived()) {
        params.put("companyProcessStepStatusTypeId", ps.getCompanyProcessStepStatusTypeId());
        params.put(
            "processStepStatusTypeId", ps.getIsRoot() ? ps.getProcessStepStatusTypeId() : null);
        sqlCache.updateBySql(insertSql, params);
      }
    }

    if (null != processStepWorkQueueType) {
      return getProcessStepStatusTypesForWorkQueueType(processStepWorkQueueType.getId(), null);
    } else {
      return getProcessStepStatusTypesForWorkQueueType(null, processStepEventWorkQueueType.getId());
    }
  }

  public List<WorkQueueTypeProjectStatus> saveEventStatusTypesToWorkQueueType(
      ProcessStepEventWorkQueueType processStepEventWorkQueueType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueType.getId());
    params.put("userId", currentUser.trueUserId());

    for (WorkQueueTypeEventStatus ps : processStepEventWorkQueueType.getEventStatuses()) {
      if (null != ps.getId() && ps.getArchived()) {
        params.put("archived", ps.getArchived());
        params.put("id", ps.getId());
        sqlCache.updateBySql(WorkQueueTypeQuery.updateEventStatusType, params);
      } else if (null == ps.getId() && !ps.getArchived()) {
        params.put("companyEventStatusTypeId", ps.getCompanyEventStatusTypeId());
        params.put("eventStatusTypeId", ps.getIsRoot() ? ps.getEventStatusTypeId() : null);
        sqlCache.updateBySql(WorkQueueTypeQuery.insertEventStatusType, params);
      }
    }

    return getEventStatusTypesForWorkQueueType(processStepEventWorkQueueType.getId());
  }

  public List<WorkQueueTypeProjectStatus> getEventStatusTypesForWorkQueueType(
      Long processStepEventWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueTypeId);

    return sqlCache.queryBySql(
      WorkQueueTypeQuery.getEventStatusesForWorkQueueType, params, WorkQueueTypeProjectStatus.class);
  }

  public List<WorkQueueTypeProjectStatus> getProjectStatusTypesForWorkQueueType(
      Long processStepWorkQueueTypeId, Long processStepEventWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepWorkQueueTypeId", processStepWorkQueueTypeId);
    params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueTypeId);
    String sql =
        null != processStepWorkQueueTypeId
            ? WorkQueueTypeQuery.getProjectStatusesForPsWorkQueueType
            : WorkQueueTypeQuery.getProjectStatusesForEventWorkQueueType;
    return sqlCache.queryBySql(sql, params, WorkQueueTypeProjectStatus.class);
  }

  public List<WorkQueueTypeProcessStepStatus> getProcessStepStatusTypesForWorkQueueType(
      Long processStepWorkQueueTypeId, Long processStepEventWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepWorkQueueTypeId", processStepWorkQueueTypeId);
    params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueTypeId);

    String sql =
        null != processStepWorkQueueTypeId
            ? WorkQueueTypeQuery.getProcessStepStatusesForPsWorkQueueType
            : WorkQueueTypeQuery.getProcessStepStatusesForEventWorkQueueType;

    return sqlCache.queryBySql(sql, params, WorkQueueTypeProcessStepStatus.class);
  }

  // event wqt stuff
  public List<WorkQueueType> getAvailableWorkQueueTypesForEvent(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());
    params.put("id", id);

    return sqlCache.queryBySql(
      WorkQueueTypeQuery.getAvailableWorkQueueTypesForEvent, params, WorkQueueType.class);
  }

  public void deleteEventWorkQueueType(Long id) {
    User currentUser = securityService.getCurrentUser();

    //this was updated to also deletes the pseWqt - events statuses, process step statuses and project statuses so that a delete-readd doesn't bring back values that it shouldnt
    sqlCache.updateBySql(
        WorkQueueTypeQuery.deleteEventWorkQueueType,
        ImmutableMap.of("id", id, "modifiedById", currentUser.trueUserId()));

    callConfigChangeFunction(null, id);
  }

  public Optional<ProcessStepEventWorkQueueType> getEventWorkQueueType(Long id) {

    return sqlCache.getBySql(
      WorkQueueTypeQuery.getProcessStepEventWorkQueueType,
        ImmutableMap.of("id", id),
        new ProcessStepEventWorkQueueTypeMapper<>(ProcessStepEventWorkQueueType.class, om));
  }

  public Optional<ProcessStepEventWorkQueueType> insertEventWorkQueueType(
      ProcessStepEventWorkQueueType wqt) {
    User currentUser = securityService.getCurrentUser();

    Long id =
        sqlCache
            .updateBySqlReturningId(
              WorkQueueTypeQuery.insertProcessStepEventWorkQueueType,
                ImmutableMap.of(
                    "createdById",
                    currentUser.trueUserId(),
                    "workQueueTypeId",
                    wqt.getWorkQueueTypeId(),
                    "processStepEventId",
                    wqt.getProcessStepEventId()),
                "id")
            .longValue();

    // handle pst on new wqt
    wqt.setId(id);
    saveProjectStatusTypesToWorkQueueType(null, wqt);
    saveProcessStepStatusTypesToWorkQueueType(null, wqt);
    saveEventStatusTypesToWorkQueueType(wqt);

    callConfigChangeFunction(null, wqt.getId());

    return getEventWorkQueueType(id);
  }

  public static class ProcessStepWorkQueueTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepWorkQueueTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<WorkQueueTypeProjectStatus>> projectStatusesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "projectStatuses",
          new JsonCollectionDeserializer(projectStatusesRef, objectMapper));

      TypeReference<List<WorkQueueTypeProcessStepStatus>> processStepStatusesRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "processStepStatuses",
          new JsonCollectionDeserializer(processStepStatusesRef, objectMapper));
    }
  }

  public static class ProcessStepEventWorkQueueTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepEventWorkQueueTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<WorkQueueTypeProjectStatus>> projectStatusesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "projectStatuses",
          new JsonCollectionDeserializer(projectStatusesRef, objectMapper));

      TypeReference<List<WorkQueueTypeProcessStepStatus>> processStepStatusesRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "processStepStatuses",
          new JsonCollectionDeserializer(processStepStatusesRef, objectMapper));

      TypeReference<List<WorkQueueTypeEventStatus>> eventStatusesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "eventStatuses",
          new JsonCollectionDeserializer(eventStatusesRef, objectMapper));
    }
  }

  public static class WorkQueueTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public WorkQueueTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<WorkQueueTypeSchedule>> wrkQueueTypeScheduleRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "schedule",
          new JsonCollectionDeserializer(wrkQueueTypeScheduleRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> whiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "hiddenWhiteListedPositions",
        new JsonCollectionDeserializer(whiteListedPositionsRef, objectMapper));
    }
  }
}
