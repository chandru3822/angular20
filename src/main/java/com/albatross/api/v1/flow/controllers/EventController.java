package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.event.Event;
import com.albatross.api.v1.flow.model.event.EventCompanyEventStatusType;
import com.albatross.api.v1.flow.model.event.EventStatusType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEvent;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeEventStatus;
import com.albatross.api.v1.flow.services.EventService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/event")
public class EventController {

  private final EventService eventService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Event> getEventsForCompany() {
    return eventService.getEventsForCompany();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Event getEvent(@PathVariable Long id) {
    return eventService.getEvent(id);
  }

  @PostMapping(value = "/{id}/saveChangesToDefaultFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveChangesToDefaultFields(@PathVariable Long id,
                                         @RequestBody Event event) {
    eventService.saveChangesToDefaultFields(id, event);
  }

  @PutMapping(value = "/delete/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<FieldInUse>> deleteEvent(@PathVariable Long id) {
    return eventService.deleteEvent(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateEvent(@RequestBody Event event) {
    eventService.updateEvent(event);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Event insertEvent(@RequestBody Event event) {
    return eventService.insertEvent(event);
  }

  //status stuff
  @GetMapping(value = "/status", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventStatusType>> getEventStatuses() {
    return new ResponseEntity<>(eventService.getEventStatuses(), HttpStatus.OK);
  }

  @GetMapping(value = "/statusesForWqt", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<WorkQueueTypeEventStatus>> getStatusesForWqt(@RequestParam Long processStepId,
                                                                          @RequestParam Long eventId) {
    return new ResponseEntity<>(eventService.getStatusesForWqt(processStepId, eventId), HttpStatus.OK);
  }

  @GetMapping(value = "/companyStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventStatusType>> getCompanyProjectStatuses() {
    return new ResponseEntity<>(eventService.getCompanyEventStatuses(), HttpStatus.OK);
  }

  @DeleteMapping(value = "/{eventId}/companyStatus/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteStatusFromEvent(@PathVariable Long id) {
    eventService.deleteStatusFromEvent(id);
  }

  @GetMapping(value = "/{eventId}/status", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CompanyEventStatusType>> getAssignedEventStatuses(@PathVariable Long eventId) {
    return new ResponseEntity<>(eventService.getAssignedEventStatuses(eventId), HttpStatus.OK);
  }

  @GetMapping(value = "/statusesForPsEvent/{psEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CompanyEventStatusType>> getAssignedProcessStepEventStatuses(@PathVariable Long psEventId) {
    return new ResponseEntity<>(eventService.getAssignedProcessStepEventStatuses(psEventId), HttpStatus.OK);
  }

  @GetMapping(value = "/{eventId}/lovStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ListOfValue>> getAssignedEventStatusesByListOfValue(@PathVariable Long eventId) {
    return new ResponseEntity<>(eventService.getAssignedEventStatusesByListOfValue(eventId), HttpStatus.OK);
  }

  @GetMapping(value = "/{eventId}/lovCategory", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ListOfValue>> getAssignedEventCategoriesByListOfValue(@PathVariable Long eventId) {
    return new ResponseEntity<>(eventService.getAssignedEventCategoriesByListOfValue(eventId), HttpStatus.OK);
  }

  @PutMapping(value = "/companyStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Optional<EventStatusType>> saveCompanyEventStatus(@RequestBody EventStatusType status) {
    return new ResponseEntity<>(eventService.saveCompanyEventStatus(status), HttpStatus.OK);
  }

  @PutMapping(value = "/companyStatuses", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveCompanyProjectStatuses(@RequestBody List<EventStatusType> statuses) {
    eventService.saveCompanyEventStatuses(statuses);
  }

  @DeleteMapping(value = "/companyStatus/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<EventController.CannotDeleteEventStatus> deleteCompanyEventStatus(@PathVariable Long id) {
    return eventService.deleteCompanyEventStatus(id);
  }

  @PostMapping(value = "/status/assignCompanyStatus/{companyStatusTypeId}/toEvent/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<EventCompanyEventStatusType> assignStatusToEvent(@PathVariable Long companyStatusTypeId,
                                                                   @PathVariable Long eventId) {
    return eventService.assignStatusToEvent(companyStatusTypeId, eventId);
  }

  @GetMapping(value = "/status/company/availableForEvent/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyEventStatusType> getAvailableStatusesForEvent (@PathVariable Long id) {
    return eventService.getAvailableStatusesForEvent(id);
  }

  @GetMapping(value = "/{eventId}/processStepEvents", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProcessStepEvent>> getProcessStepEventsByEventId(@PathVariable Long eventId) {
    return new ResponseEntity<>(eventService.getByEventId(eventId), HttpStatus.OK);
  }

  @GetMapping(value = "{eventId}/owners", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<SystemListOption>> getAvaiableOwners(@PathVariable Long eventId) {
    return new ResponseEntity<>(eventService.getAvailableOwners(eventId), HttpStatus.OK);
  }

  //white list start, end or resource field
  @PutMapping(value = "/{eventId}/saveWhiteListPositions/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveWhiteListPositions(@PathVariable Long eventId,
                                     @PathVariable Long typeId,
                                     @RequestBody List<WhiteListedPosition> whiteListedPositions) {
    eventService.saveWhiteListPositions(eventId, typeId, whiteListedPositions);
  }

  @Data
  public static class CannotDeleteEventStatus {
    private List<EventCompanyEventStatusType> events;
    private List<ProcessStepEventData> processStepEventActions;
    private List<ProcessStepEventData> processStepEventRequirements;
  }

  @Data
  public static class ProcessStepEventData {
    private String actionName, eventName, processStepName;
  }

}
