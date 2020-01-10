package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.WorkType;
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
public class WorkTypeService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<WorkType> getWorkTypes() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<WorkType> results = sqlCache.query("workType.getTypesForCompany", params, WorkType.class);
    return results;
  }

  public Optional<WorkType> getType(Long companyId, Long id) {
    return sqlCache.get("workType.getType",
        ImmutableMap.of("companyId", companyId,
            "id", id),
        WorkType.class);
  }

  public void deleteType(Long typeId) {
    sqlCache.update("workType.deleteType",
        ImmutableMap.of("id", typeId));
  }

  public void updateType(WorkType type) {
    sqlCache.update("workType.updateType",
        ImmutableMap.of("companyId", type.getCompanyId(),
            "id", type.getId(),
            "workType", type.getWorkType()));
  }

  public Optional<WorkType> insertType(WorkType type) {
    Long id = sqlCache.updateReturningId("workType.insertType",
        ImmutableMap.of("workType", type.getWorkType(),
            "companyId", type.getCompanyId()),
        "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
