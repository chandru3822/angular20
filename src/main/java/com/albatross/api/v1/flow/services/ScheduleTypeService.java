package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ScheduleType;
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
public class ScheduleTypeService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<ScheduleType> getScheduleTypes() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<ScheduleType> results = sqlCache.query("scheduleType.getTypesForCompany", params, ScheduleType.class);
    return results;
  }

  public Optional<ScheduleType> getType(Long companyId, Long id) {
    return sqlCache.get("scheduleType.getType",
        ImmutableMap.of("companyId", companyId,
            "id", id),
        ScheduleType.class);
  }

  public void deleteType(Long typeId) {
    sqlCache.update("scheduleType.deleteType",
        ImmutableMap.of("id", typeId));
  }

  public void updateType(ScheduleType type) {
    sqlCache.update("scheduleType.updateType",
        ImmutableMap.of("companyId", type.getCompanyId(),
            "id", type.getId(),
            "scheduleType", type.getScheduleType()));
  }

  public Optional<ScheduleType> insertType(ScheduleType type) {
    Long id = sqlCache.updateReturningId("scheduleType.insertType",
        ImmutableMap.of("scheduleType", type.getScheduleType(),
            "companyId", type.getCompanyId()),
        "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
