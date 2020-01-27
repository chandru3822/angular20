package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.EventType;
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
public class EventTypeService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<EventType> getEventTypes() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getParentCompanyId());

    List<EventType> results = sqlCache.query("eventType.getTypesForCompany", params, EventType.class);
    return results;
  }

  public Optional<EventType> getType(Long companyId, Long id) {
    return sqlCache.get("eventType.getType",
        ImmutableMap.of("companyId", companyId,
            "id", id),
        EventType.class);
  }

  public void deleteType(Long typeId) {
    sqlCache.update("eventType.deleteType",
        ImmutableMap.of("id", typeId));
  }

  public void updateType(EventType type) {
    sqlCache.update("eventType.updateType",
        ImmutableMap.of("companyId", type.getCompanyId(),
            "id", type.getId(),
            "eventType", type.getEventType()));
  }

  public Optional<EventType> insertType(EventType type) {
    Long id = sqlCache.updateReturningId("eventType.insertType",
        ImmutableMap.of("eventType", type.getEventType(),
            "companyId", type.getCompanyId()),
        "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
