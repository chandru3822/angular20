package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ResourceAppointment;
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

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteSchedule(@PathVariable Long id) {
    availabilityService.deleteSchedule(id);
  }

  // appointments
  @GetMapping(value = "/appointments/length", produces = MediaType.APPLICATION_JSON_VALUE)
  public Long getResourceAppointmentLength(@RequestParam(required = false) Long userId,
                                           @RequestParam(required = false) Long orgId) {
    return availabilityService.getResourceAppointmentLength(userId, orgId);
  }

  @PostMapping(value = "/appointments/length", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveResourceAppointmentLength(@RequestBody AvailabilityService.AppointmentLength al) {
    availabilityService.saveResourceAppointmentLength(al);
  }

  @GetMapping(value = "/appointments", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ResourceAppointment> getResourceAppointments(@RequestParam(required = false) Long userId,
                                                           @RequestParam(required = false) Long orgId) {
    return availabilityService.getResourceAppointments(userId, orgId);
  }

  @PostMapping(value = "/appointment", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResourceAppointment saveAppointment(@RequestBody ResourceAppointment resourceAppointment) {
    return availabilityService.saveAppointment(resourceAppointment);
  }

  @DeleteMapping(value = "/appointment/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteAppointment(@PathVariable Long id) {
    availabilityService.deleteAppointment(id);
  }
}
