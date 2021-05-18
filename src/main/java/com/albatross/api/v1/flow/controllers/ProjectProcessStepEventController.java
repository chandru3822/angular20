package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ProcessStepEvent;
import com.albatross.api.v1.flow.model.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.services.ProjectProcessStepEventService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/projectProcessStep/{ppsId}/event")
public class ProjectProcessStepEventController {

  private final ProjectProcessStepEventService projectProcessStepEventService;

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProjectProcessStepEvent> insertPpsEvent(@PathVariable Long ppsId,
                                                          @RequestBody ProcessStepEvent processStepEvent) {
      return projectProcessStepEventService.insertPpsEvent(ppsId, processStepEvent);
  }

}
