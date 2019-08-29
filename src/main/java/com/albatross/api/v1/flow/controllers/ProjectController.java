package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Project;
import com.albatross.api.v1.flow.services.ProjectService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/{companyId}/processes/{processId}/projects")
public class ProjectController {

  private final ProjectService projectService;

  @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Project>> getProjectsForProcess(@PathVariable Long companyId, @PathVariable Long processId) {
    return new ResponseEntity<>(projectService.getProjectsForProcess(companyId, processId), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Project> getProject(@PathVariable Long companyId, @PathVariable Long processId, @PathVariable Long projectId) {
    return projectService.getProject(companyId, processId, projectId)
      .map(ResponseEntity::ok)
      .orElse(ResponseEntity.notFound().build());
  }
}
