package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.CustomActionService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;


@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/customAction")
@RequiredArgsConstructor
public class CustomActionController {

  private final CustomActionService customActionService;

  @PutMapping(value = "/rescheduleCloserAppt/{ppsEventId}")
  public RescheduleResponse rescheduleCloserAppt(@PathVariable Long ppsEventId) {
    return customActionService.rescheduleCloserAppt(ppsEventId);
  }

  @Data
  public static class RescheduleResponse {
    private Boolean success;
    private Long leadSourceId;
    private String failReason, leadSource;
  }


}
