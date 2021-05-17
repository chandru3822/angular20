package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Event;
import com.albatross.api.v1.flow.services.EventService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/event")
public class EventController {

  @Autowired
  private EventService eventService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Event> getEventsForCompany() {
    return eventService.getEventsForCompany();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Event getEvent(@PathVariable Long id) {
    return eventService.getEvent(id);
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
}
