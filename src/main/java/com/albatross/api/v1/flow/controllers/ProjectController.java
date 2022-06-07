package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.DensitySearch;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAction;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.model.project.ProjectDensityResult;
import com.albatross.api.v1.flow.model.project.ProjectStatusCount;
import com.albatross.api.v1.flow.model.project.ProjectStatusType;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStep;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProjectStatus;
import com.albatross.api.v1.flow.services.MessagingService;
import com.albatross.api.v1.flow.services.ProjectService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/project", produces = MediaType.APPLICATION_JSON_VALUE)
public class ProjectController {

  private final ProjectService projectService;
  private final MessagingService messagingService;

  @GetMapping
  public ResponseEntity<List<Project>> getProjectsForProcess(@PathVariable Long processId) {
    return new ResponseEntity<>(projectService.getProjectsForProcess(processId), HttpStatus.OK);
  }

  @GetMapping(value = "/search")
  public ResponseEntity<Page<Project>> searchProjects(
      @RequestParam String query,
      @RequestParam(required = false) Long companyProjectStatusTypeId,
      @RequestParam(required = false) String overrideType,
      @RequestParam(required = false) String sortColumn,
      @RequestParam(required = false) String sortDirection,
      Pageable pageable) {
    return new ResponseEntity<>(
        projectService.searchProjects(
            query, companyProjectStatusTypeId, overrideType, sortColumn, sortDirection, pageable),
        HttpStatus.OK);
  }

  @PostMapping(value = "/search/density")
  public List<ProjectDensityResult> getProjectsInGeoArea(@RequestBody DensitySearch search) {
    return projectService.getProjectsInGeoArea(search);
  }

  @GetMapping(value = "/countsByStatus")
  public ResponseEntity<List<ProjectStatusCount>> projectCountsByStatus(
      @RequestParam(required = false) String overrideType) {
    return new ResponseEntity<>(projectService.projectCountsByStatus(overrideType), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}")
  public Optional<Project> getProject(@PathVariable Long projectId) {
    return projectService.getProject(projectId);
  }

  @DeleteMapping(value = "/{projectId}")
  public void deleteProject(@PathVariable Long projectId) {
    projectService.deleteProject(projectId);
    messagingService.deleteConversation(projectId);
  }

  @GetMapping(value = "/owners")
  public List<Owner> getOwners() {
    return projectService.getOwners();
  }

  @PutMapping(value = "")
  public ResponseEntity<Void> updateProject(@RequestBody Project project) throws Exception {
    //    currently only saves the address fields
    projectService.updateProject(project);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @PutMapping(value = "/{projectId}/owner")
  public ResponseEntity<Void> updateProjectOwner(
      @PathVariable Long projectId, @RequestBody Owner owner) {
    projectService.updateProjectOwner(projectId, owner);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/{projectId}/processSteps")
  public ResponseEntity<List<ProjectProcessStep>> getProjectProcessSteps(
      @PathVariable Long projectId) {
    return new ResponseEntity<>(
        projectService.getProcessStepsByProjectId(projectId, null), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}/upcomingProcessSteps")
  public ResponseEntity<List<ProjectProcessStep>> getUpcomingProjectProcessSteps(
      @PathVariable Long projectId) {
    return new ResponseEntity<>(
        projectService.getProcessStepsByProjectId(projectId, 1L), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}/events")
  public ResponseEntity<List<ProjectProcessStepEvent>> getProjectEvents(
      @PathVariable Long projectId) {
    return new ResponseEntity<>(
        projectService.getEventsByProjectId(projectId, null), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}/activeEvents")
  public ResponseEntity<List<ProjectProcessStepEvent>> getUpcomingProjectEvents(
      @PathVariable Long projectId) {
    return new ResponseEntity<>(projectService.getEventsByProjectId(projectId, 1L), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}/attachments")
  public ResponseEntity<List<Attachment>> getProjectAttachments(
      @PathVariable Long projectId, @PathVariable(required = false) Boolean isMobile) {
    return new ResponseEntity<>(projectService.getAttachments(projectId, isMobile), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectId}/attachment")
  public ResponseEntity<Attachment> uploadProjectAttachment(
      @PathVariable Long projectId,
      @RequestParam Long attachmentTypeId,
      @RequestParam("file") MultipartFile file)
      throws IOException {
    return new ResponseEntity<>(
        projectService.addAttachment(file, projectId, attachmentTypeId), HttpStatus.OK);
  }

  // status stuff
  @GetMapping(value = "/companyStatus")
  public ResponseEntity<List<ProjectStatusType>> getCompanyProjectStatuses(
      @RequestParam(required = false) Long projectId) {
    return new ResponseEntity<>(projectService.getCompanyProjectStatuses(projectId), HttpStatus.OK);
  }

  @GetMapping(value = "/statusesForWqt")
  public ResponseEntity<List<WorkQueueTypeProjectStatus>> getStatusesForWqt() {
    return new ResponseEntity<>(projectService.getStatusesForWqt(), HttpStatus.OK);
  }

  @PutMapping(value = "/companyStatus/initial/{id}")
  public void saveInitialProjectStatusType(@PathVariable Long id) {
    projectService.saveInitialProjectStatusType(id);
  }

  @PutMapping(value = "/companyStatus")
  public ResponseEntity<Optional<ProjectStatusType>> saveCompanyProjectStatus(
      @RequestBody ProjectStatusType status) {
    return new ResponseEntity<>(projectService.saveCompanyProjectStatus(status), HttpStatus.OK);
  }

  @PutMapping(value = "/companyStatuses")
  public void saveCompanyProjectStatuses(@RequestBody List<ProjectStatusType> statuses) {
    projectService.saveCompanyProjectStatuses(statuses);
  }

  @DeleteMapping(value = "/companyStatus/{id}")
  public ResponseEntity<ProjectController.CannotDeleteProjectStatus> deleteCompanyProjectStatus(@PathVariable Long id) {
    return projectService.deleteCompanyProjectStatus(id);
  }

  @GetMapping(value = "/status")
  public ResponseEntity<List<ProjectStatusType>> getProjectStatuses() {
    return new ResponseEntity<>(projectService.getProjectStatuses(), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectId}/status")
  public Optional<Project> updateProjectStatus(
      @PathVariable Long projectId, @RequestBody Project project) {
    // changing this to return the status object cuz i neeeeeeeed it
    return projectService.updateStatus(projectId, project.getCompanyProjectStatusTypeId());
  }

  @GetMapping(value = "/{projectId}/status")
  public Optional<Project> getProjectStatusDetails(@PathVariable Long projectId) {
    return projectService.getStatus(projectId);
  }

  @GetMapping(value = "/generate", produces = "text/csv")
  public ResponseEntity<String> generateProjectSmartlist(@RequestParam String query) {
    String report = projectService.generateReport(query);
    return new ResponseEntity<>(
        report, (report == null) ? HttpStatus.INTERNAL_SERVER_ERROR : HttpStatus.OK);
  }

  @Data
  public static class CannotDeleteProjectStatus {
    private List<Project> projectsWithStatus;
    private List<ProcessStepAction> processStepActions;
    private List<ProcessStepEventData> processStepEventRequirements;
    private List<ProcessStepEventData> processStepRequirements;
  }

  @Data
  public static class ProcessStepEventData {
    private String actionName, eventName, processStepName;
  }
}
