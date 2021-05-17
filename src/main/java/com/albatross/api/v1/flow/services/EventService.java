package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Event;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class EventService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldGroupService customFieldGroupService;
  private final ObjectMapper om;

  public List<Event> getEventsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Event> results = sqlCache.query("event.getAllForCompany", params, Event.class);
    return results;
  }

  public Event getEvent(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Event> result = sqlCache.get("event.get", params,  Event.class);
    return result.orElse(null);
  }

  public void deleteEvent(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("eventId", id);
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("event.delete", params);
  }

  public void updateEvent(Event event) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", event.getId());
    params.put("modifiedById", currentUser.getId());
    params.put("name", event.getEventName());
    sqlCache.update("event.update", params);
  }

  public Event insertEvent(Event event) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("createdById", currentUser.getId());
    params.put("name", event.getEventName());
    Long id = sqlCache.updateReturningId("event.insert", params, "id").longValue();

    return getEvent(id);
  }

}
