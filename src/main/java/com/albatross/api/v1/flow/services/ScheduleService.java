package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.ScheduleController;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.project.ProjectWithEvents;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.queries.AvailabilityQuery;
import com.albatross.api.v1.flow.queries.ProjectProcessStepEventQuery;
import com.albatross.api.v1.flow.queries.ProjectProcessStepQuery;
import com.albatross.api.v1.flow.queries.ScheduleQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@PreAuthorize("hasFeatureAccess('SCHEDULE')")
@RequiredArgsConstructor
public class ScheduleService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final UserPositionService userPositionService;


  private final ObjectMapper om;

  public List<ScheduleEvent> getEventsForCompanyByOrgAndUser(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    List<Long> combined;

    if(null != esp.getUserPositionIds()) {
      //this part can be taken out as soon as the new mobile version has been adopted - check with kory
      //BACKWARDS: 2/16/21
      combined = esp.getUserPositionIds();
    } else {
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("userIds", esp.getUserIds());
      combined = sqlCache.queryBySql(ScheduleQuery.getUserPositionIdsForUsers, p2, new SingleColumnRowMapper<>(Long.class));
    }

    if(null != esp.getOrgIds()) {
      combined.addAll(esp.getOrgIds());
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
//    params.put("userIds", esp.getUserIds());
//    params.put("orgIds", esp.getOrgIds());
    params.put("combined", combined );
    params.put("includeCancelled", esp.getIncludeCancelled() != null ? esp.getIncludeCancelled() : false );
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    List<ScheduleEvent> results = sqlCache.queryBySql(ScheduleQuery.getEvents, params, ScheduleEvent.class);
    for(ScheduleEvent event : results) {
        if(event.getCustomFieldDisplayValueGroupAssignmentId() != null) {
            HashMap<String, Object> moreParams = new HashMap<>();
            moreParams.put("objectTypeId", 6); //6 is the event object type
            moreParams.put("cfgaId", event.getCustomFieldDisplayValueGroupAssignmentId());
            moreParams.put("primaryId", event.getProjectProcessStepEventId());
            List<CustomFieldValueDisplay> cfvs = sqlCache.queryBySql(ProjectProcessStepQuery.getOneCustomFieldValue, moreParams, new CustomFieldValueDisplayMapper(CustomFieldValueDisplay.class, om));
            event.setCustomFieldDisplayValue(cfvs.get(0));
        }
    }
    return results;
  }

  public List<ScheduleEvent> getConflictingEventsForCompanyByOrgAndUser(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    List<Long> combined;

    if(null != esp.getUserPositionIds()) {
      combined = esp.getUserPositionIds();
    } else {
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("userIds", esp.getUserIds());
      combined = sqlCache.queryBySql(ScheduleQuery.getUserPositionIdsForUsers, p2, new SingleColumnRowMapper<>(Long.class));
    }

    if(null != esp.getOrgIds()) {
      combined.addAll(esp.getOrgIds());
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("combined", combined );
    params.put("includeCancelled", esp.getIncludeCancelled() != null ? esp.getIncludeCancelled() : false );
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    List<ScheduleEvent> results = sqlCache.queryBySql(ScheduleQuery.getConflictingEvents, params, ScheduleEvent.class);
    for(ScheduleEvent event : results) {
      if(event.getCustomFieldDisplayValueGroupAssignmentId() != null) {
        HashMap<String, Object> moreParams = new HashMap<>();
        moreParams.put("objectTypeId", 6); //6 is the event object type
        moreParams.put("cfgaId", event.getCustomFieldDisplayValueGroupAssignmentId());
        moreParams.put("primaryId", event.getProjectProcessStepEventId());
        List<CustomFieldValueDisplay> cfvs = sqlCache.queryBySql(ProjectProcessStepQuery.getOneCustomFieldValue, moreParams, new CustomFieldValueDisplayMapper(CustomFieldValueDisplay.class, om));
        event.setCustomFieldDisplayValue(cfvs.get(0));
      }
    }
    return results;
  }

  public Optional<ProjectWithEvents> getEventsByProject(Long projectId) {
      User user = securityService.getCurrentUser();
      Boolean systemAdmin = user.getHighestCompanyId() == 1L;
      List<Long> userPositionIds = userPositionService.getAllActiveUserPositionIds(user);
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      params.put("systemAdmin", systemAdmin);
      params.put("userPositions", userPositionIds);

    Optional<ProjectWithEvents> result = sqlCache.getBySql(ScheduleQuery.getEventsByProject, params, new ProjectWithEventsMapper<>(ProjectWithEvents.class, om));
    return result;
  }

  public String getAvailabilityForCompanyByOrgAndUser(ScheduleController.EventSearchParams esp) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("userIds", esp.getUserIds());
    params.put("orgIds", esp.getOrgIds());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    params.put("timezone", esp.getTimezone());

    String results = sqlCache.queryForObjectBySql(ScheduleQuery.getAvailability, params, String.class);

    return null == results ? "[]": results;
  }

  public Page<ScheduleEvent> getScheduleProjects(ScheduleController.EventSearchParams esp, Pageable pageable) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("companyStateId", esp.getCompanyStateId());
    params.put("eventIds", esp.getEventIds());
    params.put("processStepStatusTypeId", esp.getProcessStepStatusTypeId());
    params.put("eventStatusTypeId", esp.getEventStatusTypeId());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("search", esp.getSearch());
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());
    List<ScheduleEvent> results = sqlCache.queryBySql(ScheduleQuery.getProjects, params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
    Integer total = sqlCache.queryForObjectBySql(ScheduleQuery.getProjectsCount, params, Integer.class);
    return new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), total);
  }

  public List<ListOfValue> getAvailableProjectResource(ScheduleController.ResourceRequest req) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", req.getCompanyId());
    params.put("systemListId", req.getSystemListId());
    params.put("resourceId", req.getResourceId());
    params.put("systemListOptionIds", req.getSystemListOptionIds());
    List<ListOfValue> results = sqlCache.queryBySql(ScheduleQuery.getAvailableProjectResources, params, ListOfValue.class);
    return results;
  }

  public List<ScheduleEvent> getProject(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("projectId", esp.getProjectId());
    params.put("eventId", esp.getEventId());
    params.put("processStepStatusTypeId", esp.getProcessStepStatusTypeId());
    params.put("eventStatusTypeId", esp.getEventStatusTypeId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("projectProcessStepEventId", esp.getProjectProcessStepEventId());
    List<ScheduleEvent> results = sqlCache.queryBySql(ScheduleQuery.getProject, params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
    return results;
  }

  public List<ScheduleEvent> searchProjectsByName(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("search", esp.getSearch());
    params.put("isParent", isParent);

    List<ScheduleEvent> results = sqlCache.queryBySql(ScheduleQuery.searchProjectsByName, params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
    return results;
  }

  public void saveEvent(ScheduleEvent ev) {
    // i dont love this but if we try to do it how the other screens do it we would have to restructure all the fields back into individual CustomFieldValue objects and i dont like that option either _rn
    if(null != ev.getStart() && null != ev.getEnd() && null != ev.getResourceId()) {
      User user = securityService.getCurrentUser();
      HashMap<String, Object> params = new HashMap<>();

      params.put("id", ev.getProjectProcessStepEventId());
      params.put("startTime", ev.getStart());
      params.put("endTime", ev.getEnd());
      params.put("companyEventStatusTypeId", ev.getCompanyEventStatusTypeId());
      params.put("resourceId", ev.getResourceId());
      params.put("saveVersion", ev.getSaveVersion());
      params.put("modifiedById", user.getId());
      //i am lazy and didn't want to re-code the frontend so this this calls the right function even though that seems weird
      int countUpdatedRows = sqlCache.updateBySql(ProjectProcessStepEventQuery.savePpsEventDetails, params);
      if (countUpdatedRows == 0) {
        throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Save Version Mismatch", new Exception());
      }
    }

  }

  public List<ScheduleEvent> checkForSchedulingConflict(ScheduleEvent saveEvent, Long eventId){
    if(saveEvent.getStart() == null || saveEvent.getEnd() == null){
      return null;
    }
    List<ScheduleEvent> eventList = new ArrayList<>();

    List<ResourceAppointment> appointments = getResourceAppointmentsInRange(saveEvent.getResourceId(), null, saveEvent.getStart().toString(), saveEvent.getEnd().toString());

    for(ResourceAppointment appointment : appointments){
      ScheduleEvent appointmentEvent = new ScheduleEvent();
      appointmentEvent.setResourceName(saveEvent.getResourceName());
      appointmentEvent.setStart(new Timestamp(appointment.getStartTime().getTime()));
      appointmentEvent.setEnd(new Timestamp(appointment.getEndTime().getTime()));
      appointmentEvent.setEventName(appointment.getTitle());
      appointmentEvent.setProjectName("Personal Appointment");
      appointmentEvent.setProjectId(999L);
      eventList.add(appointmentEvent);
    }

    ArrayList<Long> resourceIds = new ArrayList<>();
    resourceIds.add(saveEvent.getResourceId());
    ScheduleController.EventSearchParams params = new ScheduleController.EventSearchParams();
    params.setUserPositionIds(resourceIds);
    params.setStartTime(saveEvent.getStart().toString());
    params.setEndTime(saveEvent.getEnd().toString());
    List<ScheduleEvent> events = getConflictingEventsForCompanyByOrgAndUser(params);
    for(ScheduleEvent event : events){
      if(event.getProjectProcessStepEventId().equals(saveEvent.getProjectProcessStepEventId()) || event.getStart().equals(saveEvent.getEnd()) || event.getEnd().equals(saveEvent.getStart())){
        continue;
      }
      else{
        eventList.add(event);
      }
    }
    return eventList;
  }

  public List<ResourceAppointment> getResourceAppointmentsInRange(
    Long userId, List<Long> orgIds, String startTime, String endTime) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("orgIds", orgIds);
    params.put("startTime", startTime);
    params.put("endTime", endTime);
    params.put("companyId", user.getCompanyId());
    List<ResourceAppointment> results =
      sqlCache.queryBySql(
        AvailabilityQuery.getAppointmentsForOneResourceInRange, params, ResourceAppointment.class);

    return results;
  }

  public Page<ResourceAppointment> getResourceAppointments(
    Long userId, Long orgId, Pageable pageable) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("orgId", orgId);
    params.put("companyId", user.getCompanyId());
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<ResourceAppointment> results =
      sqlCache.queryBySql(
        AvailabilityQuery.getAppointmentsForResource, params, ResourceAppointment.class);
    Integer count =
      sqlCache.queryForObjectBySql(
        AvailabilityQuery.getAppointmentsForResourceCount, params, Integer.class);

    return new PageImpl<>(
      results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  public static class ScheduleEventMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ScheduleEventMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ListOfValue>> resourcesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "resources",
          new JsonCollectionDeserializer(resourcesRef, objectMapper));

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "systemListOptionIds",
        new JsonCollectionDeserializer(systemListOptionIdsRef, objectMapper));
    }
  }

  public static class ProjectWithEventsMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProjectWithEventsMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ProjectProcessStepEvent>> eventsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "events",
          new JsonCollectionDeserializer(eventsRef, objectMapper));
    }
  }


}
