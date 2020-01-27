package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ScheduleEvent;
import com.albatross.api.v1.flow.services.ScheduleService;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by Randa Nunn on 2019-10-22
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/schedule")
public class ScheduleController {

  @Autowired
  private ScheduleService scheduleService;

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleEvent> getEventsForCompanyByOrgAndUser(@RequestBody EventSearchParams params) {
    return scheduleService.getEventsForCompanyByOrgAndUser(params);
  }

  @PostMapping(value = "/projects", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleEvent> getScheduleProjects(@RequestBody EventSearchParams params) {
    return scheduleService.getScheduleProjects(params);
  }

  @PostMapping(value = "/getProject", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleEvent> getProject(@RequestBody EventSearchParams params) {
    //this returns a list because of how the UI currently works. probably will change this later
    return scheduleService.getProject(params);
  }

  @PostMapping(value = "/projects/search", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleEvent> searchProjectsByName(@RequestBody EventSearchParams params) {
    return scheduleService.searchProjectsByName(params);
  }

  @PostMapping(value = "/saveEvent", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveEvent(@RequestBody ScheduleEvent ev) {
    scheduleService.saveEvent(ev);
  }


  @Data
  public static class EventSearchParams {
    private List<Long> userIds, orgIds, eventTypeIds;
    private String startTime, endTime, search;
    private Long stateId, projectId, eventTypeId;
  }

}
