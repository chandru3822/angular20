package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ResourceSchedule;
import com.albatross.api.v1.flow.model.WorkDay;
import com.albatross.api.v1.flow.services.AvailabilityService;
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
@RequestMapping(value = "/api/v1/flow/availability")
public class AvailabilityController {

  @Autowired
  private AvailabilityService availabilityService;


  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ResourceSchedule> getResourceAvailability(@RequestParam(required = false) Long userId,
                                                        @RequestParam(required = false) Long orgId) {
    return availabilityService.getResourceAvailability(userId, orgId);
  }

  @GetMapping(value = "/workDays", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkDay> getWorkDays() {
    return availabilityService.getWorkDays();
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResourceSchedule saveSchedule(@RequestBody ResourceSchedule resourceAvailability) {
    return availabilityService.saveSchedule(resourceAvailability);
  }
}
