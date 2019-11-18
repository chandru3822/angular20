package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.ScheduleController;
import com.albatross.api.v1.flow.model.ListOfValue;
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
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userIds", esp.getUserIds());
    params.put("orgIds", esp.getOrgIds());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    List<ScheduleEvent> results = sqlCache.query("schedule.getEvents", params, ScheduleEvent.class);
    return results;
  }
  // todo: @randa schedule.getProjects, schedule.getProject and schedule.getEvents are the exact same query except for the where clause. can we make them one? _rn
  public List<ScheduleEvent> getScheduleProjects(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("stateId", esp.getStateId());
    params.put("stepIds", esp.getStepIds());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    List<ScheduleEvent> results = sqlCache.query("schedule.getProjects", params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
    return results;
  }

  public List<ScheduleEvent> getProject(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("projectId", esp.getProjectId());
    params.put("processStepId", esp.getProcessStepId());
    params.put("startTime", esp.getStartTime());
    params.put("endTime", esp.getEndTime());
    List<ScheduleEvent> results = sqlCache.query("schedule.getProject", params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
    return results;
  }

  public List<ScheduleEvent> searchProjectsByName(ScheduleController.EventSearchParams esp) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("search", esp.getSearch());

    List<ScheduleEvent> results = sqlCache.query("schedule.searchProjectsByName", params, new ScheduleEventMapper<>(ScheduleEvent.class, om));
    return results;
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
