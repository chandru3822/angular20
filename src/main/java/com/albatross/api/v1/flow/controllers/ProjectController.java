package com.albatross.api.v1.flow.controllers;

import java.util.List;

import com.albatross.api.v1.flow.model.Project;
import com.albatross.api.v1.flow.model.ProjectProcessStep;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.albatross.api.v1.flow.services.ProjectService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/project")
public class ProjectController {

  private final ProjectService projectService;

  private final CustomFieldValueService customFieldValueService;

  @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Project>> getProjectsForProcess(@PathVariable Long processId) {
    return new ResponseEntity<>(projectService.getProjectsForProcess(processId), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Project> getProject(@PathVariable Long projectId) {
    // @TODO: wtf do we need a processId here?
    return projectService.getProject(projectId)
      .map(ResponseEntity::ok)
      .orElse(ResponseEntity.notFound().build());
  }

  @GetMapping(value = "/{projectId}/processSteps", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProjectProcessStep>> getProjectProcessSteps(@PathVariable Long projectId) {
    return new ResponseEntity<>(projectService.getProcessStepsByProjectId(projectId), HttpStatus.OK);
  }
}
