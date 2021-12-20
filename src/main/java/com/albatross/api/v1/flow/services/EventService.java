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
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;

import java.util.*;


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
    Optional<Event> result = sqlCache.get("event.get", params,  new EventMapper<>(Event.class, om));
    return result.orElse(null);
  }

  public void saveResourceField(Long id, Long resourceCustomFieldId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());
    params.put("resourceCustomFieldId", resourceCustomFieldId);
    sqlCache.update("event.saveResourceField", params);
  }

  public void deleteEvent(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("eventId", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("event.delete", params);
  }

  public void updateEvent(Event event) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", event.getId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("name", event.getEventName());
    params.put("resourceCustomFieldId", event.getResourceCustomFieldId());
    sqlCache.update("event.update", params);
  }

  public Event insertEvent(Event event) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("createdById", currentUser.trueUserId());
    params.put("name", event.getEventName());
    params.put("resourceCustomFieldId", event.getResourceCustomFieldId());
    Long id = sqlCache.updateReturningId("event.insert", params, "id").longValue();

    return getEvent(id);
  }

  public List<EventStatusType> getEventStatuses() {
    List<EventStatusType> results = sqlCache.query("event.getStatuses", Collections.emptyMap(), EventStatusType.class);

    return results;
  }

  public List<CompanyEventStatusType> getAssignedEventStatuses(Long eventId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);
    List<CompanyEventStatusType> results = sqlCache.query("event.getAssignedStatuses", params, CompanyEventStatusType.class);

    return results;
  }

  public List<ListOfValue> getAssignedEventStatusesByListOfValue(Long eventId) {
    final Long companyId = securityService.getCurrentUser().getCompanyId();
    return sqlCache.query("event.getAssignedEventStatusesByListOfValue", Map.of("eventId", eventId, "companyId", companyId), ListOfValue.class);
  }

  public List<ListOfValue> getAssignedEventCategoriesByListOfValue(Long eventId) {
    final Long companyId = securityService.getCurrentUser().getCompanyId();
    return sqlCache.query("event.getAssignedEventCategoriesByListOfValue", Map.of("eventId", eventId, "companyId", companyId), ListOfValue.class);
  }

  public List<EventStatusType> getCompanyEventStatuses() {
    User currentUser = securityService.getCurrentUser();
    Long companyId = currentUser.getCompanyId();

    List<EventStatusType> results = sqlCache.query("event.getCompanyStatuses",
      ImmutableMap.of("companyId", companyId), EventStatusType.class);

    return results;
  }

  public Optional<EventStatusType> getOneCompanyEventStatusType(Long id) {
    Optional<EventStatusType> result = sqlCache.get("event.getOneCompanyStatus",
      ImmutableMap.of("id", id), EventStatusType.class);

    return result;
  }

  public void saveCompanyEventStatuses(List<EventStatusType> statuses) {
    for (EventStatusType s : statuses) {
      saveCompanyEventStatus(s);
    }
  }

  public Optional<EventStatusType> saveCompanyEventStatus(EventStatusType status) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("rootEventStatusTypeId", status.getEventStatusTypeId());
    params.put("eventStatusType", status.getEventStatusType());
    params.put("companyId", currentUser.getCompanyId());
    Long id;

    if(null != status.getId()) {
      id = status.getId();
      params.put("id", id);
      params.put("displayOrder", status.getDisplayOrder());
      sqlCache.update("event.updateCompanyStatus", params);
    } else {
      id = sqlCache.updateReturningId("event.insertCompanyStatus", params, "id").longValue();
    }

    return getOneCompanyEventStatusType(id);
  }

  public void deleteStatusFromEvent(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("id", id);

    sqlCache.update("event.deleteStatusFromEvent", params);
  }

  public void deleteCompanyEventStatus(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("id", id);

    sqlCache.update("event.deleteCompanyStatus", params);
  }

  public Optional<EventCompanyEventStatusType> assignStatusToEvent(Long companyEventStatusTypeId, Long eventId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);
    params.put("companyEventStatusTypeId", companyEventStatusTypeId);
    params.put("createdById", currentUser.trueUserId());

    Long id = sqlCache.updateReturningId("event.assignStatusToEvent", params, "id").longValue();
    return getEventCompanyProcessStepStatusType(id);
  }

  public Optional<EventCompanyEventStatusType> getEventCompanyProcessStepStatusType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<EventCompanyEventStatusType> result = sqlCache.get("event.getEventCompanyEventStatusType", params, EventCompanyEventStatusType.class);
    return result;
  }

  public List<CompanyEventStatusType> getAvailableStatusesForEvent(Long eventId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);
    params.put("companyId", user.getCompanyId());

    List<CompanyEventStatusType> companyEventStatusTypes = sqlCache.query("event.availableStatusesForEvent", params, CompanyEventStatusType.class);
    return companyEventStatusTypes;
  }

  public List<ProcessStepEvent> getByEventId(Long eventId) {
    return sqlCache.query("event.getProcessStepEventsByEventId", Map.of("eventId", eventId), new ProcessStepEventService.ProcessStepEventMapper<>(ProcessStepEvent.class, om));
  }

  /**
   * Get available resource owners for the given eventId
   * @param eventId
   * @return List<SystemListOption>
   */
  public List<SystemListOption> getAvailableOwners(Long eventId) {
    var companyId = securityService.getCurrentUser().getCompanyId();
    List<Map<String, Object>> results = sqlCache.query("event.getAvailableOwners", Map.of("eventId", eventId, "companyId", companyId), new ColumnMapRowMapper());
    var options = new ArrayList<SystemListOption>();
    results.forEach(r -> {
      options.add(new SystemListOption(Long.parseLong(r.get("id").toString()), r.get("name").toString()));
    });
    return options;
  }

  public static class EventMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public EventMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef = new TypeReference<List<CustomFieldGroup>>() {};
      bw.registerCustomEditor(List.class, "customFieldGroups",
        new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));

      TypeReference<List<EventCompanyEventStatusType>> companyEventStatusTypeRef = new TypeReference<List<EventCompanyEventStatusType>>() {};
      bw.registerCustomEditor(List.class, "companyEventStatusTypes",
        new JsonCollectionDeserializer(companyEventStatusTypeRef, objectMapper));
    }
  }

}
