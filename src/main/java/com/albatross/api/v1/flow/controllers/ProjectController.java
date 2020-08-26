package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.ProjectService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/project")
public class ProjectController {

  private final ProjectService projectService;

  @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Project>> getProjectsForProcess(@PathVariable Long processId) {
    return new ResponseEntity<>(projectService.getProjectsForProcess(processId), HttpStatus.OK);
  }

  @GetMapping(value= "/search", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Page<Project>> searchProjects(@RequestParam String query, Pageable pageable) {
    return new ResponseEntity<>(projectService.searchProjects(query, pageable), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Project> getProject(@PathVariable Long projectId) {
    return projectService.getProject(projectId)
      .map(ResponseEntity::ok)
      .orElse(ResponseEntity.notFound().build());
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateProject(@RequestBody Project project) {
//    currently only saves the address fields
    projectService.updateProject(project);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/{projectId}/processSteps", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProjectProcessStep>> getProjectProcessSteps(@PathVariable Long projectId) {
    return new ResponseEntity<>(projectService.getProcessStepsByProjectId(projectId), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}/attachments", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Attachment>> getProjectAttachments(@PathVariable Long projectId,
                                                                @PathVariable(required = false) Boolean isMobile) {
    return new ResponseEntity<>(projectService.getAttachments(projectId, isMobile), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectId}/attachment", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Attachment> uploadProjectAttachment(@PathVariable Long projectId,
                                                   @RequestParam Long attachmentTypeId,
                                                   @RequestParam("file") MultipartFile file) throws IOException {
    return new ResponseEntity<>(projectService.addAttachment(file, projectId, attachmentTypeId), HttpStatus.OK);
  }

  @GetMapping(value = "/owners", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Owner>> getAvailableProjectOwners() {
    return new ResponseEntity<>(projectService.getOwners(), HttpStatus.OK);
  }

  @GetMapping(value = "/status", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProjectStatus>> getProjectStatuses() {
      return new ResponseEntity<>(projectService.getStatuses(), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectId}/status", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateProjectStatus(@PathVariable Long projectId, @RequestBody Project project) {
      projectService.updateStatus(projectId, project.getCompanyProjectStatusTypeId());
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/generate", produces = "text/csv")
  public ResponseEntity<String> generateProjectSmartlist(@RequestParam String query) {
    String report = projectService.generateReport(query);
    return new ResponseEntity<>(report, (report == null) ? HttpStatus.INTERNAL_SERVER_ERROR : HttpStatus.OK);
  }
}
