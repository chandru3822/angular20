package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.services.ProjectService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/projectProcessStep")
public class ProjectProcessStepController {

  private final ProjectService projectService;

  // @GetMapping(value = "/{processStepId", produces = MediaType.APPLICATION_JSON_VALUE)
  // public ResponseEntity<ProjectProcessStep> getProjectProcessStepById(@PathVariable Long processStepId) {

  //   return new ResponseEntity<>(projectService.getProjectProcessStep(processStepId), HttpStatus.OK);
  // }
}
