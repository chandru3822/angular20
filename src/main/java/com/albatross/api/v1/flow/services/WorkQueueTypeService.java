package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProcessStepWorkQueueType;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.WorkQueueType;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class WorkQueueTypeService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

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

  public Optional<WorkQueueType> getType(Long id) {
    return sqlCache.get("workQueueType.getType",
        ImmutableMap.of("id", id),
        WorkQueueType.class);
  }

  public void deleteType(Long typeId) {
    User user = securityService.getCurrentUser();
    sqlCache.update("workQueueType.deleteType",
        ImmutableMap.of("id", typeId,
            "modifiedById", user.getId()));
  }


  public Optional<WorkQueueType> updateType(WorkQueueType type) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId() );
    params.put("id", type.getId() );
    params.put("modifiedById", user.getId() );
    params.put("workQueueCategoryId", type.getWorkQueueCategoryId() );
    params.put("displayOrder", type.getDisplayOrder() );
    params.put("workQueueType", type.getWorkQueueType() );

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
    Long id = sqlCache.updateReturningId("workQueueType.insertType",
        ImmutableMap.of("workQueueType", type.getWorkQueueType(),
            "createdById", user.getId(),
            "workQueueCategoryId", type.getWorkQueueCategoryId(),
            "companyId", user.getCompanyId()),
        "id").longValue();

    return getType(id);
  }

  public void deleteProcessStepWorkQueueType(Long id) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update("workQueueType.deleteProcessStepWorkQueueType",
      ImmutableMap.of("id", id,
        "modifiedById", currentUser.getId()));
  }

  public Optional<ProcessStepWorkQueueType> getProcessStepWorkQueueType(Long id) {
    Optional<ProcessStepWorkQueueType> result = sqlCache.get("workQueueType.getProcessStepWorkQueueType",
      ImmutableMap.of("id", id), ProcessStepWorkQueueType.class);

    return result;
  }

  public Optional<ProcessStepWorkQueueType> insertProcessStepWorkQueueType(ProcessStepWorkQueueType wqt) {
    User currentUser = securityService.getCurrentUser();

    Long id = sqlCache.updateReturningId("workQueueType.insertProcessStepWorkQueueType",
      ImmutableMap.of("createdById", currentUser.getId(),
        "workQueueTypeId", wqt.getWorkQueueTypeId(),
        "processStepId", wqt.getProcessStepId()), "id").longValue();

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

}
