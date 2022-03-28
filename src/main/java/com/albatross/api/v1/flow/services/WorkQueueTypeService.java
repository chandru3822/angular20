package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
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

    String sql = sqlCache.getByKey("workQueueType.getTypesForCompany");
    sql += orderBy;
    return sqlCache.queryBySql(sql, params, WorkQueueType.class);
  }

  public List<DurationType> getDurationTypes() {
    return sqlCache.query(
        "workQueueType.getDurationTypes", Collections.emptyMap(), DurationType.class);
  }

  public Optional<WorkQueueType> getType(Long id) {
    return sqlCache.get(
        "workQueueType.getType",
        ImmutableMap.of("id", id),
        new WorkQueueTypeMapper<>(WorkQueueType.class, om));
  }

  public void deleteType(Long typeId) {
    User user = securityService.getCurrentUser();
    sqlCache.update(
        "workQueueType.deleteType",
        ImmutableMap.of("id", typeId, "modifiedById", user.trueUserId()));
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
    sqlCache.update("workQueueType.updateType", params);

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
    Long id = sqlCache.updateReturningId("workQueueType.insertType", params, "id").longValue();

    // any time a work queue type is created we need to create a smartlist placeholder for any
    // custom fields in the dropdown
    params.put("workQueueTypeId", id);
    // this is the root object type, then we combine it with company id to get the
    // company_object_type_id
    params.put("objectTypeId", useEventData ? ObjectType.EVENT.id : ObjectType.PROCESS_STEP.id);
    sqlCache.update("workQueueType.addSmartlist", params);

    return getType(id);
  }

  public void deleteProcessStepWorkQueueType(Long id) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update(
        "workQueueType.deleteProcessStepWorkQueueType",
        ImmutableMap.of("id", id, "modifiedById", currentUser.trueUserId()));

    callConfigChangeFunction(id, null);
  }

  public Optional<ProcessStepWorkQueueType> getProcessStepWorkQueueType(Long id) {

    return sqlCache.get(
        "workQueueType.getProcessStepWorkQueueType",
        ImmutableMap.of("id", id),
        new ProcessStepWorkQueueTypeMapper<>(ProcessStepWorkQueueType.class, om));
  }

  public Optional<ProcessStepWorkQueueType> insertProcessStepWorkQueueType(
      ProcessStepWorkQueueType wqt) {
    User currentUser = securityService.getCurrentUser();

    Long id =
        sqlCache
            .updateReturningId(
                "workQueueType.insertProcessStepWorkQueueType",
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

    return sqlCache.query(
        "workQueueType.getAvailableWorkQueueTypesForStep", params, WorkQueueType.class);
  }

  public List<WorkQueueTypeProjectStatus> saveProjectStatusTypesToWorkQueueType(
      ProcessStepWorkQueueType processStepWorkQueueType,
      ProcessStepEventWorkQueueType processStepEventWorkQueueType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    String insertSqlKey = "workQueueType.insertProjectStatusTypeForProcessStep";
    String updateSqlKey = "workQueueType.updateProjectStatusTypeForProcessStep";
    if (null != processStepWorkQueueType) {
      params.put("processStepWorkQueueTypeId", processStepWorkQueueType.getId());
    } else {
      params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueType.getId());
      insertSqlKey = "workQueueType.insertProjectStatusTypeForEvent";
      updateSqlKey = "workQueueType.updateProjectStatusTypeForEvent";
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
        String sql = sqlCache.getByKey(updateSqlKey);
        sqlCache.updateBySql(sql, params);
      } else if (null == ps.getId() && !ps.getArchived()) {
        params.put("companyProjectStatusTypeId", ps.getCompanyProjectStatusTypeId());
        params.put("projectStatusTypeId", ps.getIsRoot() ? ps.getProjectStatusTypeId() : null);
        String sql = sqlCache.getByKey(insertSqlKey);
        sqlCache.updateBySql(sql, params);
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
      sqlCache.queryForObject("workQueueType.callPsConfigChangeFunction", params, String.class);
    } else {
      sqlCache.queryForObject("workQueueType.callEventConfigChangeFunction", params, String.class);
    }
  }

  public List<WorkQueueTypeProcessStepStatus> saveProcessStepStatusTypesToWorkQueueType(
      ProcessStepWorkQueueType processStepWorkQueueType,
      ProcessStepEventWorkQueueType processStepEventWorkQueueType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    String insertSqlKey = "workQueueType.insertProcessStepStatusTypeForProcessStep";
    String updateSqlKey = "workQueueType.updateProcessStepStatusTypeForProcessStep";
    if (null != processStepWorkQueueType) {
      params.put("processStepWorkQueueTypeId", processStepWorkQueueType.getId());
    } else {
      params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueType.getId());
      insertSqlKey = "workQueueType.insertProcessStepStatusTypeForEvent";
      updateSqlKey = "workQueueType.updateProcessStepStatusTypeForEvent";
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
        String sql = sqlCache.getByKey(updateSqlKey);
        sqlCache.updateBySql(sql, params);
      } else if (null == ps.getId() && !ps.getArchived()) {
        params.put("companyProcessStepStatusTypeId", ps.getCompanyProcessStepStatusTypeId());
        params.put(
            "processStepStatusTypeId", ps.getIsRoot() ? ps.getProcessStepStatusTypeId() : null);
        String sql = sqlCache.getByKey(insertSqlKey);
        sqlCache.updateBySql(sql, params);
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
        sqlCache.update("workQueueType.updateEventStatusType", params);
      } else if (null == ps.getId() && !ps.getArchived()) {
        params.put("companyEventStatusTypeId", ps.getCompanyEventStatusTypeId());
        params.put("eventStatusTypeId", ps.getIsRoot() ? ps.getEventStatusTypeId() : null);
        sqlCache.update("workQueueType.insertEventStatusType", params);
      }
    }

    return getEventStatusTypesForWorkQueueType(processStepEventWorkQueueType.getId());
  }

  public List<WorkQueueTypeProjectStatus> getEventStatusTypesForWorkQueueType(
      Long processStepEventWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueTypeId);

    return sqlCache.query(
        "workQueueType.getEventStatusesForWorkQueueType", params, WorkQueueTypeProjectStatus.class);
  }

  public List<WorkQueueTypeProjectStatus> getProjectStatusTypesForWorkQueueType(
      Long processStepWorkQueueTypeId, Long processStepEventWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepWorkQueueTypeId", processStepWorkQueueTypeId);
    params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueTypeId);
    String sqlKey =
        null != processStepWorkQueueTypeId
            ? "workQueueType.getProjectStatusesForPsWorkQueueType"
            : "workQueueType.getProjectStatusesForEventWorkQueueType";
    String sql = sqlCache.getByKey(sqlKey);
    return sqlCache.queryBySql(sql, params, WorkQueueTypeProjectStatus.class);
  }

  public List<WorkQueueTypeProcessStepStatus> getProcessStepStatusTypesForWorkQueueType(
      Long processStepWorkQueueTypeId, Long processStepEventWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepWorkQueueTypeId", processStepWorkQueueTypeId);
    params.put("processStepEventWorkQueueTypeId", processStepEventWorkQueueTypeId);

    String sqlKey =
        null != processStepWorkQueueTypeId
            ? "workQueueType.getProcessStepStatusesForPsWorkQueueType"
            : "workQueueType.getProcessStepStatusesForEventWorkQueueType";
    String sql = sqlCache.getByKey(sqlKey);

    return sqlCache.queryBySql(sql, params, WorkQueueTypeProcessStepStatus.class);
  }

  // event wqt stuff
  public List<WorkQueueType> getAvailableWorkQueueTypesForEvent(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());
    params.put("id", id);

    return sqlCache.query(
        "workQueueType.getAvailableWorkQueueTypesForEvent", params, WorkQueueType.class);
  }

  public void deleteEventWorkQueueType(Long id) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update(
        "workQueueType.deleteEventWorkQueueType",
        ImmutableMap.of("id", id, "modifiedById", currentUser.trueUserId()));

    callConfigChangeFunction(null, id);
  }

  public Optional<ProcessStepEventWorkQueueType> getEventWorkQueueType(Long id) {

    return sqlCache.get(
        "workQueueType.getProcessStepEventWorkQueueType",
        ImmutableMap.of("id", id),
        new ProcessStepEventWorkQueueTypeMapper<>(ProcessStepEventWorkQueueType.class, om));
  }

  public Optional<ProcessStepEventWorkQueueType> insertEventWorkQueueType(
      ProcessStepEventWorkQueueType wqt) {
    User currentUser = securityService.getCurrentUser();

    Long id =
        sqlCache
            .updateReturningId(
                "workQueueType.insertProcessStepEventWorkQueueType",
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
    }
  }
}
