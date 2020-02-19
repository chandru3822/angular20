package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.WorkQueueType;
import com.albatross.api.v1.flow.model.User;
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

  public List<WorkQueueType> getWorkQueueTypes() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());

    List<WorkQueueType> results = sqlCache.query("workQueueType.getTypesForCompany", params, WorkQueueType.class);
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
    sqlCache.update("workQueueType.updateType",
        ImmutableMap.of("companyId", user.getCompanyId(),
            "id", type.getId(),
            "modifiedById", user.getId(),
            "workQueueCategoryId", type.getWorkQueueCategoryId(),
            "workQueueType", type.getWorkQueueType()));

    return getType(type.getId());
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


}
