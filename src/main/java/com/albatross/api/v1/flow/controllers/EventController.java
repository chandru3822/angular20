package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.EventService;
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

  @PostMapping(value = "/{id}/saveResourceField/{resourceCustomFieldId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveResourceField(@PathVariable Long id,
                        @PathVariable Long resourceCustomFieldId) {
    eventService.saveResourceField(id, resourceCustomFieldId);
  }

  @PutMapping(value = "/delete/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteEvent(@PathVariable Long id) {
    eventService.deleteEvent(id);
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

  @GetMapping(value = "/companyStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventStatusType>> getCompanyProjectStatuses() {
    return new ResponseEntity<>(eventService.getCompanyEventStatuses(), HttpStatus.OK);
  }

  @GetMapping(value = "/{eventId}/status", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CompanyEventStatusType>> getAssignedEventStatuses(@PathVariable Long eventId) {
    return new ResponseEntity<>(eventService.getAssignedEventStatuses(eventId), HttpStatus.OK);
  }

  @PutMapping(value = "/companyStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Optional<EventStatusType>> saveCompanyProjectStatus(@RequestBody EventStatusType status) {
    return new ResponseEntity<>(eventService.saveCompanyEventStatus(status), HttpStatus.OK);
  }

  @DeleteMapping(value = "/companyStatus/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCompanyProjectStatus(@PathVariable Long id) {
    eventService.deleteCompanyEventStatus(id);
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

}
