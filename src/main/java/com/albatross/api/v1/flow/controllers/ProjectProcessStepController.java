package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ProjectProcessStep;
import com.albatross.api.v1.flow.services.ProjectService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import lombok.RequiredArgsConstructor;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/projectProcessStep")
public class ProjectProcessStepController {

  private final ProjectService projectService;

  @GetMapping(value = "/{processStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ProjectProcessStep> getProjectProcessStepById(@PathVariable Long processStepId) {

    return new ResponseEntity<>(projectService.getProjectProcessStep(processStepId), HttpStatus.OK);
  }

  @GetMapping(value = "/{processStepId}/actionResult/{actionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<String> getActionResult(@PathVariable Long processStepId, @PathVariable Long actionId) {
    try {
      boolean canComplete = projectService.canCompleteAction(actionId, processStepId);
      return new ResponseEntity<>(String.format("{\"canComplete\": %s}", canComplete), HttpStatus.OK);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }
}
