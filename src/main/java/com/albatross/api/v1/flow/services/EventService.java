package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.EventController;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.event.Event;
import com.albatross.api.v1.flow.model.event.EventCompanyEventStatusType;
import com.albatross.api.v1.flow.model.event.EventStatusType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEvent;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeEventStatus;
import com.albatross.api.v1.flow.queries.EventQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.*;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccess('EVENTS')")
@RequiredArgsConstructor
public class EventService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<Event> getEventsForCompany() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(EventQuery.getAllForCompany, params, Event.class);
  }

  public Event getEvent(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.getBySql(EventQuery.get, params, new EventMapper<>(Event.class, om)).orElse(null);
  }

  public void saveChangesToDefaultFields(Long id, Event event) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());
    params.put("resourceCustomFieldId", event.getResourceCustomFieldId());
    params.put("startTimeReadOnly", event.getStartTimeReadOnly());
    params.put("endTimeReadOnly", event.getEndTimeReadOnly());
    params.put("resourceReadOnly", event.getResourceReadOnly());
    sqlCache.updateBySql(EventQuery.saveChangesToDefaultFields, params);
  }

  public ResponseEntity<List<FieldInUse>> deleteEvent(Long id) {
    User currentUser = securityService.getCurrentUser();

    List<FieldInUse> fields = getProcessStepsUsingEvent(id);
    if (!fields.isEmpty()) {
      return ResponseEntity.badRequest().body(fields);
    } else {
      Map<String, Object> params = new HashMap<>();
      params.put("eventId", id);
      params.put("modifiedById", currentUser.trueUserId());

      sqlCache.updateBySql(EventQuery.delete, params);
      return ResponseEntity.ok().build();
    }
  }

  public List<FieldInUse> getProcessStepsUsingEvent(Long eventId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);
    List<FieldInUse> fieldsInUse = sqlCache.queryBySql(EventQuery.getProcessStepsUsingEvent, params, FieldInUse.class);
    return fieldsInUse;
  }

  public void updateEvent(Event event) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("id", event.getId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("name", event.getEventName());
    sqlCache.updateBySql(EventQuery.update, params);
  }

  public Event insertEvent(Event event) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("createdById", currentUser.trueUserId());
    params.put("name", event.getEventName());
    params.put("resourceCustomFieldId", event.getResourceCustomFieldId());
    Long id = sqlCache.updateBySqlReturningId(EventQuery.insert, params, "id").longValue();

    return getEvent(id);
  }

  public List<EventStatusType> getEventStatuses() {
    return sqlCache.queryBySql(EventQuery.getStatuses, Collections.emptyMap(), EventStatusType.class);
  }

  public List<WorkQueueTypeEventStatus> getStatusesForWqt(Long processStepId, Long eventId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("processStepId", processStepId);
    params.put("eventId", eventId);
    return sqlCache.queryBySql(EventQuery.getStatusesForWqt, params, WorkQueueTypeEventStatus.class);
  }

  public List<CompanyEventStatusType> getAssignedEventStatuses(Long eventId) {
    Map<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);

    return sqlCache.queryBySql(EventQuery.getAssignedStatuses, params, CompanyEventStatusType.class);
  }

  public List<CompanyEventStatusType> getAssignedProcessStepEventStatuses(Long pseId) {
    Map<String, Object> params = new HashMap<>();
    params.put("pseId", pseId);

    return sqlCache.queryBySql(EventQuery.getAssignedProcessStepEventStatuses, params, CompanyEventStatusType.class);
  }

  public List<ListOfValue> getAssignedEventStatusesByListOfValue(Long eventId) {
    final Long companyId = securityService.getCurrentUser().getCompanyId();
    return sqlCache.queryBySql(
      EventQuery.getAssignedEventStatusesByListOfValue,
        Map.of("eventId", eventId, "companyId", companyId),
        ListOfValue.class);
  }

  public List<ListOfValue> getAssignedEventCategoriesByListOfValue(Long eventId) {
    final Long companyId = securityService.getCurrentUser().getCompanyId();
    return sqlCache.queryBySql(
      EventQuery.getAssignedEventCategoriesByListOfValue,
        Map.of("eventId", eventId, "companyId", companyId),
        ListOfValue.class);
  }

  public List<EventStatusType> getCompanyEventStatuses() {
    User currentUser = securityService.getCurrentUser();
    Long companyId = currentUser.getCompanyId();

    return sqlCache.queryBySql(
      EventQuery.getCompanyStatuses, ImmutableMap.of("companyId", companyId), EventStatusType.class);
  }

  public Optional<EventStatusType> getOneCompanyEventStatusType(Long id) {
    return sqlCache.getBySql(
      EventQuery.getOneCompanyStatus, ImmutableMap.of("id", id), EventStatusType.class);
  }

  public void saveCompanyEventStatuses(List<EventStatusType> statuses) {
    for (EventStatusType s : statuses) {
      saveCompanyEventStatus(s);
    }
  }

  public Optional<EventStatusType> saveCompanyEventStatus(EventStatusType status) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("rootEventStatusTypeId", status.getEventStatusTypeId());
    params.put("eventStatusType", status.getEventStatusType());
    params.put("companyId", currentUser.getCompanyId());
    Long id;

    if (null != status.getId()) {
      id = status.getId();
      params.put("id", id);
      params.put("displayOrder", status.getDisplayOrder());
      sqlCache.updateBySql(EventQuery.updateCompanyStatus, params);
    } else {
      id = sqlCache.updateBySqlReturningId(EventQuery.insertCompanyStatus, params, "id").longValue();
    }

    return getOneCompanyEventStatusType(id);
  }

  public void deleteStatusFromEvent(Long id) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("id", id);

    sqlCache.updateBySql(EventQuery.deleteStatusFromEvent, params);
  }

  public ResponseEntity<EventController.CannotDeleteEventStatus> deleteCompanyEventStatus(Long id) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("id", id);

    EventController.CannotDeleteEventStatus cannotDelete = new EventController.CannotDeleteEventStatus();
    List<EventCompanyEventStatusType> events = sqlCache.queryBySql(EventQuery.getEventsWithStatusInUse, Map.of("id", id), EventCompanyEventStatusType.class);
    List<EventController.ProcessStepEventData> processStepEventActions = sqlCache.queryBySql(EventQuery.getPseaWithStatusInUse, Map.of("id", id), EventController.ProcessStepEventData.class);
    List<EventController.ProcessStepEventData> processStepRequirement = sqlCache.queryBySql(EventQuery.getPsrWithStatusInUse, Map.of("id", id), EventController.ProcessStepEventData.class);
    if (events.isEmpty() && processStepEventActions.isEmpty() && processStepRequirement.isEmpty()) {
      sqlCache.updateBySql(EventQuery.deleteCompanyStatus, params);
      return ResponseEntity.ok().build();
    }
    else {
      cannotDelete.setEvents(events);
      cannotDelete.setProcessStepEventActions(processStepEventActions);
      cannotDelete.setProcessStepEventRequirements(processStepRequirement);
      return ResponseEntity.badRequest().body(cannotDelete);
    }

  }

  public Optional<EventCompanyEventStatusType> assignStatusToEvent(
      Long companyEventStatusTypeId, Long eventId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);
    params.put("companyEventStatusTypeId", companyEventStatusTypeId);
    params.put("createdById", currentUser.trueUserId());

    Long id = sqlCache.updateBySqlReturningId(EventQuery.assignStatusToEvent, params, "id").longValue();
    return getEventCompanyProcessStepStatusType(id);
  }

  public Optional<EventCompanyEventStatusType> getEventCompanyProcessStepStatusType(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(
      EventQuery.getEventCompanyEventStatusType, params, EventCompanyEventStatusType.class);
  }

  public List<CompanyEventStatusType> getAvailableStatusesForEvent(Long eventId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);
    params.put("companyId", user.getCompanyId());

    return sqlCache.queryBySql(EventQuery.availableStatusesForEvent, params, CompanyEventStatusType.class);
  }

  public List<ProcessStepEvent> getByEventId(Long eventId) {
    return sqlCache.queryBySql(
      EventQuery.getProcessStepEventsByEventId,
        Map.of("eventId", eventId),
        new ProcessStepEventService.ProcessStepEventMapper<>(ProcessStepEvent.class, om));
  }

  /**
   * Get available resource owners for the given eventId
   *
   * @param eventId
   * @return List<SystemListOption>
   */
  public List<SystemListOption> getAvailableOwners(Long eventId) {
    var companyId = securityService.getCurrentUser().getCompanyId();
    List<Map<String, Object>> results =
        sqlCache.queryBySql(
          EventQuery.getAvailableOwners,
            Map.of("eventId", eventId, "companyId", companyId),
            new ColumnMapRowMapper());
    var options = new ArrayList<SystemListOption>();
    results.forEach(
        r ->
            options.add(
                new SystemListOption(
                    Long.parseLong(r.get("id").toString()), r.get("name").toString())));
    return options;
  }

  public void saveWhiteListPositions(
      Long eventId, Long whiteListTypeId, List<WhiteListedPosition> whiteListedPositions) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("eventId", eventId);
    params.put("whiteListTypeId", whiteListTypeId);

    if (whiteListedPositions.isEmpty()) {
      // if white list is empty then remove all
      sqlCache.updateBySql(EventQuery.archiveWhiteListPositions, params);
    } else {
      // archive any positions no longer assigned
      List<Long> positionIdsUsed =
          whiteListedPositions.stream().map(WhiteListedPosition::getPositionId).toList();
      params.put("positionIdsUsed", positionIdsUsed);
      sqlCache.updateBySql(EventQuery.archiveUnusedWhiteListPositions, params);

      for (WhiteListedPosition wlp : whiteListedPositions) {
        params.put("positionId", wlp.getPositionId());
        // this insert checks if there is already a non-archived row with the same values
        sqlCache.updateBySql(EventQuery.insertWhiteListPosition, params);
      }
    }
  }

  public static class EventMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public EventMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef =
          new TypeReference<List<CustomFieldGroup>>() {};
      bw.registerCustomEditor(
          List.class,
          "customFieldGroups",
          new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));

      TypeReference<List<EventCompanyEventStatusType>> companyEventStatusTypeRef =
          new TypeReference<List<EventCompanyEventStatusType>>() {};
      bw.registerCustomEditor(
          List.class,
          "companyEventStatusTypes",
          new JsonCollectionDeserializer(companyEventStatusTypeRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> startTimeWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "startTimeWhiteListedPositions",
          new JsonCollectionDeserializer(startTimeWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> endTimeWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "endTimeWhiteListedPositions",
          new JsonCollectionDeserializer(endTimeWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> resourceWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "resourceWhiteListedPositions",
          new JsonCollectionDeserializer(resourceWhiteListedPositionsRef, objectMapper));
    }
  }
}
