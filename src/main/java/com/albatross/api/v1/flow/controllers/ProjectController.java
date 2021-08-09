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
import java.util.Optional;

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
  public ResponseEntity<Page<Project>> searchProjects(@RequestParam String query,
                                                      @RequestParam(required = false) Long companyProjectStatusTypeId,
                                                      @RequestParam(required = false) String overrideType,
                                                      @RequestParam(required = false) String sortColumn,
                                                      @RequestParam(required = false) String sortDirection,
                                                      Pageable pageable) {
    return new ResponseEntity<>(projectService.searchProjects(query, companyProjectStatusTypeId, overrideType, sortColumn, sortDirection, pageable), HttpStatus.OK);
  }

  @PostMapping(value= "/search/density", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Project> getProjectsInGeoArea(@RequestBody DensitySearch search) {
    return projectService.getProjectsInGeoArea(search);
  }

  @GetMapping(value= "/countsByStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProjectStatusCount>> projectCountsByStatus(@RequestParam(required = false) String overrideType) {
    return new ResponseEntity<List<ProjectStatusCount>>(projectService.projectCountsByStatus(overrideType), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Project> getProject(@PathVariable Long projectId) {
    return projectService.getProject(projectId)
      .map(ResponseEntity::ok)
      .orElse(ResponseEntity.notFound().build());
  }

  @DeleteMapping(value = "/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProject(@PathVariable Long projectId) {
    projectService.deleteProject(projectId);
  }

  @GetMapping(value = "/owners", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Owner> getOwners() {
    return projectService.getOwners();
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateProject(@RequestBody Project project) {
//    currently only saves the address fields
    projectService.updateProject(project);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @PutMapping(value = "/{projectId}/owner", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateProjectOwner(@PathVariable Long projectId,
                                                 @RequestBody Owner owner) {
    projectService.updateProjectOwner(projectId, owner);
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

  //status stuff
  @GetMapping(value = "/companyStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProjectStatusType>> getCompanyProjectStatuses(@RequestParam(required = false) Long projectId) {
      return new ResponseEntity<>(projectService.getCompanyProjectStatuses(projectId), HttpStatus.OK);
  }

  @PutMapping(value = "/companyStatus/initial/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveInitialProjectStatusType(@PathVariable Long id) {
    projectService.saveInitialProjectStatusType(id);
  }

  @PutMapping(value = "/companyStatus", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Optional<ProjectStatusType>> saveCompanyProjectStatus(@RequestBody ProjectStatusType status) {
    return new ResponseEntity<>(projectService.saveCompanyProjectStatus(status), HttpStatus.OK);
  }

  @PutMapping(value = "/companyStatuses", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveCompanyProjectStatuses(@RequestBody List<ProjectStatusType> statuses) {
    projectService.saveCompanyProjectStatuses(statuses);
  }

  @DeleteMapping(value = "/companyStatus/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCompanyProjectStatus(@PathVariable Long id) {
    projectService.deleteCompanyProjectStatus(id);
  }

  @GetMapping(value = "/status", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProjectStatusType>> getProjectStatuses() {
    return new ResponseEntity<>(projectService.getProjectStatuses(), HttpStatus.OK);
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
