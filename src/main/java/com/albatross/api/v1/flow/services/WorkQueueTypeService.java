package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class WorkQueueTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<WorkQueueType> getWorkQueueTypes(Boolean sortByName) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());
    params.put("orderByName", null != sortByName ? sortByName : false);
    String orderBy = Boolean.TRUE.equals(sortByName) ? "order by wqt.work_queue_type" : "order by wqc.display_order, wqt.display_order, wqt.work_queue_type";

    String sql = sqlCache.getByKey("workQueueType.getTypesForCompany");
    sql += orderBy;
    List<WorkQueueType> results = sqlCache.queryBySql(sql, params, WorkQueueType.class);
    return results;
  }

  public List<DurationType> getDurationTypes() {
    List<DurationType> results = sqlCache.query("workQueueType.getDurationTypes", Collections.emptyMap(), DurationType.class);
    return results;
  }

  public Optional<WorkQueueType> getType(Long id) {
    return sqlCache.get("workQueueType.getType",
        ImmutableMap.of("id", id),
        WorkQueueType.class);
  }

  public void deleteType(Long typeId) {
    User user = securityService.getCurrentUser();
    sqlCache.update("workQueueType.deleteType",
        ImmutableMap.of("id", typeId,
            "modifiedById", user.trueUserId()));
  }


  public Optional<WorkQueueType> updateType(WorkQueueType type) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId() );
    params.put("id", type.getId() );
    params.put("modifiedById", user.trueUserId() );
    params.put("workQueueCategoryId", type.getWorkQueueCategoryId() );
    params.put("displayOrder", type.getDisplayOrder() );
    params.put("workQueueType", type.getWorkQueueType() );
    params.put("shortWindow", type.getShortWindow() );
    params.put("shortWindowDurationTypeId", type.getShortWindowDurationTypeId() );
    params.put("longWindow", type.getLongWindow() );
    params.put("longWindowDurationTypeId", type.getLongWindowDurationTypeId() );
    params.put("expectedCycle", type.getExpectedCycle() );
    params.put("expectedCycleDurationTypeId", type.getExpectedCycleDurationTypeId() );
    params.put("inverseExpectation", null != type.getInverseExpectation() ? type.getInverseExpectation() : false );
    params.put("expectedTarget", type.getExpectedTarget() );

    sqlCache.update("workQueueType.updateType", params);

    return getType(type.getId());
  }

  public void updateTypeDisplayOrders(List<WorkQueueType> types) {
    for(WorkQueueType type : types) {
      //save each display_order (i guess i can just call the full update - will do the same thing)
      updateType(type);
    }
//    return getWorkQueueTypes();
  }

  public Optional<WorkQueueType> insertType(WorkQueueType type) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueType", type.getWorkQueueType());
    params.put("createdById", user.trueUserId());
    params.put("workQueueCategoryId", type.getWorkQueueCategoryId());
    params.put("companyId", user.getCompanyId());
    Long id = sqlCache.updateReturningId("workQueueType.insertType", params, "id").longValue();

    //any time a work queue type is created we need to create a smartlist placeholder for any custom fields in the dropdown
    params.put("workQueueTypeId", id);
    sqlCache.update("workQueueType.addSmartlist", params);

    return getType(id);
  }

  public void deleteProcessStepWorkQueueType(Long id) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update("workQueueType.deleteProcessStepWorkQueueType",
      ImmutableMap.of("id", id,
        "modifiedById", currentUser.trueUserId()));
  }

  public Optional<ProcessStepWorkQueueType> getProcessStepWorkQueueType(Long id) {
    Optional<ProcessStepWorkQueueType> result = sqlCache.get("workQueueType.getProcessStepWorkQueueType",
      ImmutableMap.of("id", id), new ProcessStepWorkQueueTypeMapper<>(ProcessStepWorkQueueType.class, om));

    return result;
  }

  public Optional<ProcessStepWorkQueueType> insertProcessStepWorkQueueType(ProcessStepWorkQueueType wqt) {
    User currentUser = securityService.getCurrentUser();

    Long id = sqlCache.updateReturningId("workQueueType.insertProcessStepWorkQueueType",
      ImmutableMap.of("createdById", currentUser.trueUserId(),
        "workQueueTypeId", wqt.getWorkQueueTypeId(),
        "processStepId", wqt.getProcessStepId()), "id").longValue();

    //handle pst on new wqt
    wqt.setId(id);
    saveProjectStatusTypesToWorkQueueType(wqt);
    saveProcessStepStatusTypesToWorkQueueType(wqt);

    return getProcessStepWorkQueueType(id);
  }

  public List<WorkQueueType> getAvailableWorkQueueTypesForStep(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());
    params.put("id", id);

    List<WorkQueueType> links = sqlCache.query("workQueueType.getAvailableWorkQueueTypesForStep", params, WorkQueueType.class);
    return links;
  }

  public List<WorkQueueTypeProjectStatus> saveProjectStatusTypesToWorkQueueType(ProcessStepWorkQueueType processStepWorkQueueType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepWorkQueueTypeId", processStepWorkQueueType.getId());
    params.put("userId", currentUser.getId());

    for(WorkQueueTypeProjectStatus ps : processStepWorkQueueType.getProjectStatuses()) {
      if(null != ps.getId() && ps.getArchived()) {
        params.put("archived", ps.getArchived());
        params.put("id", ps.getId());
        sqlCache.update("workQueueType.updateProjectStatusType", params);
      } else if (null == ps.getId()) {
        params.put("companyProjectStatusTypeId", ps.getCompanyProjectStatusTypeId());
        params.put("projectStatusTypeId", ps.getProjectStatusTypeId());
        sqlCache.update("workQueueType.insertProjectStatusType", params);
      }
    }

    return getProjectStatusTypesForWorkQueueType(processStepWorkQueueType.getId());
  }

  public List<WorkQueueTypeProcessStepStatus> saveProcessStepStatusTypesToWorkQueueType(ProcessStepWorkQueueType processStepWorkQueueType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepWorkQueueTypeId", processStepWorkQueueType.getId());
    params.put("userId", currentUser.getId());

    for(WorkQueueTypeProcessStepStatus ps : processStepWorkQueueType.getProcessStepStatuses()) {
      if(null != ps.getId() && ps.getArchived()) {
        params.put("archived", ps.getArchived());
        params.put("id", ps.getId());
        sqlCache.update("workQueueType.updateProcessStepStatusType", params);
      } else if (null == ps.getId()) {
        params.put("companyProcessStepStatusTypeId", ps.getCompanyProcessStepStatusTypeId());
        params.put("processStepStatusTypeId", ps.getProcessStepStatusTypeId());
        sqlCache.update("workQueueType.insertProcessStepStatusType", params);
      }
    }

    return getProcessStepStatusTypesForWorkQueueType(processStepWorkQueueType.getId());
  }

  public List<WorkQueueTypeProjectStatus> getProjectStatusTypesForWorkQueueType (Long processStepWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepWorkQueueTypeId", processStepWorkQueueTypeId);

    List<WorkQueueTypeProjectStatus> results = sqlCache.query("workQueueType.getProjectStatusesForWorkQueueType", params, WorkQueueTypeProjectStatus.class);
    return results;
  }

  public List<WorkQueueTypeProcessStepStatus> getProcessStepStatusTypesForWorkQueueType (Long processStepWorkQueueTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepWorkQueueTypeId", processStepWorkQueueTypeId);

    List<WorkQueueTypeProcessStepStatus> results = sqlCache.query("workQueueType.getProcessStepStatusesForWorkQueueType", params, WorkQueueTypeProcessStepStatus.class);
    return results;
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
      bw.registerCustomEditor(List.class, "projectStatuses",
              new JsonCollectionDeserializer(projectStatusesRef, objectMapper));

      TypeReference<List<WorkQueueTypeProcessStepStatus>> processStepStatusesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "processStepStatuses",
        new JsonCollectionDeserializer(processStepStatusesRef, objectMapper));
    }
  }

}
