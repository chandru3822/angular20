package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.ProjectWithEvents;
import com.albatross.api.v1.flow.model.ScheduleEvent;
import com.albatross.api.v1.flow.services.ScheduleService;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

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

  @GetMapping(value = "/project/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProjectWithEvents> getEventsByProject(@PathVariable Long id) {
    return scheduleService.getEventsByProject(id);
  }

  @PostMapping(value = "/availability", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getAvailabilityForCompanyByOrgAndUser(@RequestBody EventSearchParams params) {
    return scheduleService.getAvailabilityForCompanyByOrgAndUser(params);
  }

  @PostMapping(value = "/projects", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleEvent> getScheduleProjects(@RequestBody EventSearchParams params) {
    return scheduleService.getScheduleProjects(params);
  }

  @PostMapping(value = "/projectResources", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ListOfValue> getAvailableProjectResources(@RequestBody ResourceRequest request) {
    return scheduleService.getAvailableProjectResource(request);
  }

  @PostMapping(value = "/getProject", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleEvent> getProject(@RequestBody EventSearchParams params) {
    //this returns a list because if they search for canceled or complete they could get more than one
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
    private List<Long> userIds, orgIds, eventIds, userPositionIds, postalCodeZoneUserIds;
    private String startTime, endTime, search;
    private Long companyStateId, projectId, eventId, processStepStatusTypeId, eventStatusTypeId, projectProcessStepId;
  }

  @Data
  public static class ResourceRequest {
    private List<Long> systemListOptionIds;
    private Long companyId, systemListId, resourceId;
  }

}
