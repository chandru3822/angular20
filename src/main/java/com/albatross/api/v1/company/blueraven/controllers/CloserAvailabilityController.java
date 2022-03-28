package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.CloserAvailabilityService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/closerAvailability")
@RequiredArgsConstructor
public class CloserAvailabilityController {

  private final CloserAvailabilityService closerAvailabilityService;

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getBrsCloserAvailability(@RequestBody EventSearchParams params) {
    return closerAvailabilityService.getBrsCloserAvailability(params);
  }

  @Data
  public static class EventSearchParams {
    private List<Long> userIds, orgIds, eventTypeIds, userPositionIds, postalCodeZoneUserIds;
    private String startTime, endTime, search;
    private Long companyStateId,
        projectId,
        eventTypeId,
        processStepStatusTypeId,
        projectProcessStepId;
  }
}
