package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ProcessStepStatusType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class WorkQueueService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<WorkQueue> getWorkQueues(Long workQueueCategoryId, Long userPositionId, Boolean unassigned) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueCategoryId", workQueueCategoryId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userPositionId", userPositionId);
    params.put("unassigned", null == unassigned ? false : unassigned);
    params.put("processStepStatusTypeId", ProcessStepStatusType.ACTIVE.id);

    List<WorkQueue> results = sqlCache.query("workQueue.getWorkQueues", params, WorkQueue.class);
    return results;
  }

  public List<WorkQueueDetail> getWorkQueueDetails(Long workQueueTypeId, Long userPositionId, Boolean unassigned) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueTypeId", workQueueTypeId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userPositionId", userPositionId);
    params.put("unassigned", null == unassigned ? false : unassigned);
    params.put("processStepStatusTypeId", ProcessStepStatusType.ACTIVE.id);

    List<WorkQueueDetail> results = sqlCache.query("workQueue.getProcessStepsByTypeId", params, new WorkQueueDetailMapper<>(WorkQueueDetail.class, om));
    return results;
  }

  public List<WorkQueueOwner> getWorkQueueOwners() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("processStepStatusTypeId", ProcessStepStatusType.ACTIVE.id);

    List<WorkQueueOwner> results = sqlCache.query("workQueue.getWorkQueueOwners", params, WorkQueueOwner.class);
    return results;
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
      bw.registerCustomEditor(List.class, "owningPositions",
          new JsonCollectionDeserializer(owningPositionsRef, objectMapper));

    }
  }
}
