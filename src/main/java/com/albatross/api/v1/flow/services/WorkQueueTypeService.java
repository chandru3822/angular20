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
    params.put("companyId", user.getCompanyId());

    List<WorkQueueType> results = sqlCache.query("workQueueType.getTypesForCompany", params, WorkQueueType.class);
    return results;
  }

  public Optional<WorkQueueType> getType(Long companyId, Long id) {
    return sqlCache.get("workQueueType.getType",
        ImmutableMap.of("companyId", companyId,
            "id", id),
        WorkQueueType.class);
  }

  public void deleteType(Long typeId) {
    sqlCache.update("workQueueType.deleteType",
        ImmutableMap.of("id", typeId));
  }

  public void updateType(WorkQueueType type) {
    sqlCache.update("workQueueType.updateType",
        ImmutableMap.of("companyId", type.getCompanyId(),
            "id", type.getId(),
            "workQueueType", type.getWorkQueueType()));
  }

  public Optional<WorkQueueType> insertType(WorkQueueType type) {
    Long id = sqlCache.updateReturningId("workQueueType.insertType",
        ImmutableMap.of("workQueueType", type.getWorkQueueType(),
            "companyId", type.getCompanyId()),
        "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
