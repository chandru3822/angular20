package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.ScheduleController;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.ScheduleAvailability;
import com.albatross.api.v1.flow.model.ScheduleEvent;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ScheduleService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<ScheduleEvent> getEventsForCompanyByOrgAndUser(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    List<Long> combined = esp.getUserPositionIds();
    if(null != esp.getOrgIds()) {
      combined.addAll(esp.getOrgIds());
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
//    params.put("userIds", esp.getUserIds());
//    params.put("orgIds", esp.getOrgIds());
    params.put("combined", combined );
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    List<ScheduleEvent> results = sqlCache.query("schedule.getEvents", params, ScheduleEvent.class);
    return results;
  }

  public List<ScheduleAvailability> getAvailabilityForCompanyByOrgAndUser(ScheduleController.EventSearchParams esp) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("userIds", esp.getUserIds());
    params.put("orgIds", esp.getOrgIds());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());

    List<ScheduleAvailability> results = sqlCache.query("schedule.getAvailability", params, ScheduleAvailability.class);

    return results;
  }

  // todo: @randa schedule.getProjects, schedule.getProject and schedule.getEvents are the exact same query except for the where clause. can we make them one? _rn
  public List<ScheduleEvent> getScheduleProjects(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("stateId", esp.getStateId());
    params.put("eventTypeIds", esp.getEventTypeIds());
    params.put("processStepStatusTypeIds", esp.getProcessStepStatusTypeIds());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    List<ScheduleEvent> results = sqlCache.query("schedule.getProjects", params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
    return results;
  }

  public List<ScheduleEvent> getProject(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("projectId", esp.getProjectId());
    params.put("eventTypeId", esp.getEventTypeId());
    params.put("processStepStatusTypeId", esp.getProcessStepStatusTypeId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("projectProcessStepId", esp.getProjectProcessStepId());
    List<ScheduleEvent> results = sqlCache.query("schedule.getProject", params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
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

    List<ScheduleEvent> results = sqlCache.query("schedule.searchProjectsByName", params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
    return results;
  }

  public void saveEvent(ScheduleEvent ev) {
    // i dont love this but if we try to do it how the other screens do it we would have to restructure all the fields back into individual CustomFieldValue objects and i dont like that option either _rn
    if(null != ev.getStart() && null != ev.getEnd() && null != ev.getResourceId()) {
      User user = securityService.getCurrentUser();
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectProcessStepId", ev.getProjectProcessStepId());
      params.put("modifiedById", user.getId());
      params.put("createdById", user.getId());

      //default values so we can call the same query all the other ones do
      params.put("dateValue", null);
      params.put("timestampValue", null);
      params.put("booleanValue", false);
      params.put("textValue", null);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("intArrayValue", null);

      // save the start time
      params.put("timestampValue", ev.getStart());
      params.put("customFieldGroupAssignmentId", ev.getStartCustomFieldGroupAssignmentId());
      if(null != ev.getStartCustomFieldValueId()) {
        params.put("id", ev.getStartCustomFieldValueId());
        sqlCache.update("customFieldValues.process_step.updateCustomFieldValue", params);
      } else {
        params.put("sourceId", ev.getProjectProcessStepId());
        sqlCache.update("customFieldValues.process_step.insertCustomFieldValue", params);
      }

      // reset the params - although i dont think this is actually necessary
      params.remove("customFieldGroupAssignmentId");
      params.remove("timestampValue");
      params.remove("id");

      // save the end time
      params.put("timestampValue", ev.getEnd());
      params.put("customFieldGroupAssignmentId", ev.getEndCustomFieldGroupAssignmentId());
      if(null != ev.getEndCustomFieldValueId()) {
        params.put("id", ev.getEndCustomFieldValueId());
        sqlCache.update("customFieldValues.process_step.updateCustomFieldValue", params);
      } else {
        sqlCache.update("customFieldValues.process_step.insertCustomFieldValue", params);
      }

      // reset the params - although i dont think this is actually necessary
      params.remove("customFieldGroupAssignmentId");
      params.replace("timestampValue", null);
      params.remove("id");

      // save the resourceId
      params.put("intValue", ev.getResourceId());
      params.put("customFieldGroupAssignmentId", ev.getResourceCustomFieldGroupAssignmentId());
      if(null != ev.getResourceCustomFieldValueId()) {
        params.put("id", ev.getResourceCustomFieldValueId());
        sqlCache.update("customFieldValues.process_step.updateCustomFieldValue", params);
      } else {
        sqlCache.update("customFieldValues.process_step.insertCustomFieldValue", params);
      }
    }

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
    }
  }


}
