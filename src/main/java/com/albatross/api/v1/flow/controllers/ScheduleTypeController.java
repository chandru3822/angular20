package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ScheduleType;
import com.albatross.api.v1.flow.services.ScheduleTypeService;
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
@RequestMapping(value = "/api/v1/flow/scheduleType")
public class ScheduleTypeController {

  @Autowired
  private ScheduleTypeService scheduleTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleType> getScheduleTypes () {
    return scheduleTypeService.getScheduleTypes();
  }

  @DeleteMapping(value = "/type/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    scheduleTypeService.deleteType(typeId);
  }

  @PutMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateType(@RequestBody ScheduleType type) {
    scheduleTypeService.updateType(type);
  }

  @PostMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ScheduleType> insertType(@RequestBody ScheduleType type) {
    return scheduleTypeService.insertType(type);
  }

}
