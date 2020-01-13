package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.EventType;
import com.albatross.api.v1.flow.services.EventTypeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/eventType")
public class EventTypeController {

  @Autowired
  private EventTypeService eventTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<EventType> getEventTypes () {
    return eventTypeService.getEventTypes();
  }

  @DeleteMapping(value = "/type/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    eventTypeService.deleteType(typeId);
  }

  @PutMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateType(@RequestBody EventType type) {
    eventTypeService.updateType(type);
  }

  @PostMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<EventType> insertType(@RequestBody EventType type) {
    return eventTypeService.insertType(type);
  }

}
