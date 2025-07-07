package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.company.blueraven.models.MarketoProject;
import com.albatross.api.v1.company.blueraven.services.MarketoService;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.project.*;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStep;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.services.MessagingService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.albatross.api.v1.flow.services.ProjectStatusService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/project", produces = MediaType.APPLICATION_JSON_VALUE)
public class ProjectController {

  private final ProjectService projectService;
  private final ProjectStatusService projectStatusService;
  private final MessagingService messagingService;
  private final MarketoService marketoService;

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
    @RequestParam(required = false) Boolean includeCommissionDetails,
    @RequestParam(required = false) String searchColumn,
    Pageable pageable) {
    return new ResponseEntity<>(
      projectService.searchProjects(
        query, companyProjectStatusTypeId, overrideType, sortColumn, sortDirection, includeCommissionDetails, pageable, searchColumn),
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

  @PostMapping(value = "/{projectId}/resetContact")
  public void resetProjectContactToParent(@PathVariable Long projectId) {
    projectService.resetProjectContactToParent(projectId);
  }

  @Data
  public static class ChildProjectRequest {
    private Long childProjectCount, childCompanyProcessId;
  }

  @GetMapping(value = "/{parentProjectId}/children/simple")
  public String getProjectChildren(@PathVariable Long parentProjectId) {
    return projectService.getProjectChildren(parentProjectId, true);
  }

  @GetMapping(value = "/{parentProjectId}/children/details")
  public String getProjectChildrenWithFields(@PathVariable Long parentProjectId) {
    return projectService.getProjectChildren(parentProjectId, false);
  }

  @PutMapping(value = "/{parentProjectId}/children/details")
  public void saveProjectChildrenDetails(@PathVariable Long parentProjectId,
                                           @RequestBody String fields) {
    projectService.saveProjectChildrenDetails(parentProjectId, fields);
  }

  @GetMapping(value = "/childrenHeaders")
  public List<ChildProjectHeader> getProjectChildrenHeaders() {
    return projectService.getProjectChildrenHeaders();
  }

  @GetMapping(value = "/{projectId}/statusFields")
  public List<ProjectStatusField> getStatusFieldsByProject(@PathVariable Long projectId) {
    return projectService.getStatusFieldsByProject(projectId, null);
  }

  @GetMapping(value = "/{projectId}/statusFields/{companyProjectStatusTypeId}")
  public List<ProjectStatusField> getStatusFieldsByProjectForStatus(@PathVariable Long projectId,
                                                                    @PathVariable Long companyProjectStatusTypeId) {
    return projectService.getStatusFieldsByProject(projectId, companyProjectStatusTypeId);
  }

  @DeleteMapping(value = "/{projectId}")
  public void deleteProject(
    @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    projectService.deleteProject(projectId);
    messagingService.closeThreadConversation(null, projectId, null, details.getTrueUserId());
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

  @PutMapping(value = "/contactProjects")
  public ResponseEntity<Void> updateProjectsFromContact(@RequestParam Boolean updateProjectName, @RequestParam Boolean updateProjectAddress, @RequestBody Contact contact) throws Exception {
      projectService.updateProjectFromContact(contact, updateProjectName, updateProjectAddress);
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

  @GetMapping(value = "/{projectId}/workQueueHistory")
  public ResponseEntity<List<ProjectWorkQueueHistory>> getProjectWorkQueuHistory(
    @PathVariable Long projectId) {
    return new ResponseEntity<>(
      projectService.getWorkQueueHistoryByProjectId(projectId), HttpStatus.OK);
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
  public ResponseEntity<List<Attachment>> getProjectAttachments(@PathVariable Long projectId,
                                                                @RequestParam(required = false) Boolean isMobile,
                                                                @RequestParam(required = false) Boolean linked) {
    return new ResponseEntity<>(projectService.getAttachments(projectId, isMobile, linked), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectId}/combinedAttachments")
  public ResponseEntity<List<Attachment>> getProjectCombinedAttachments(@PathVariable Long projectId,
                                                                        @RequestParam(required = false) Long ppsId,
                                                                        @RequestParam(required = false) Long ppsEventId) {
    return new ResponseEntity<>(projectService.getCombinedAttachments(projectId, ppsId, ppsEventId), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectId}/linkAttachment/{attachmentId}")
  public void linkAttachment(@PathVariable Long projectId,
                             @PathVariable Long attachmentId,
                             @RequestParam Boolean doLink) {
    projectService.linkAttachment(projectId, attachmentId, doLink);
  }

  @PostMapping(value = "/{projectId}/attachment")
  public ResponseEntity<Attachment> uploadProjectAttachment(
    @PathVariable Long projectId,
    @RequestParam Long attachmentTypeId,
    @RequestParam(required = false) String displayName,
    @RequestParam MultipartFile file)
    throws IOException {
    if (displayName == null) {
      displayName = file.getOriginalFilename();
    }
    try {
      Attachment attachment = projectService.addAttachment(file, projectId, attachmentTypeId, displayName);
      return new ResponseEntity<>(attachment, HttpStatus.OK);
    } catch (Exception e) {
      log.error("[Project Attachment] Error creating attachment msg={}", e.getMessage());
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  @PostMapping(value = "/{projectId}/attachments")
  public ResponseEntity<List<Attachment>> uploadMultipleProjectAttachments(
    @PathVariable Long projectId,
    @RequestParam Long attachmentTypeId,
    @RequestParam("files") MultipartFile[] files)
    throws IOException {

    return new ResponseEntity<>(
      projectService.addAttachments(files, projectId, attachmentTypeId), HttpStatus.OK);
  }

  // status stuff - i cant move these to their own controller because mobile uses some of them and i dont want to find out which ones right now.
  // but i did make a controller for new stuff
  @GetMapping(value = "/companyStatus")
  public ResponseEntity<List<ProjectStatusType>> getCompanyProjectStatuses(
    @RequestParam(required = false) Long projectId,
    @RequestParam(required = false) Boolean excludeAttachments) {
    return new ResponseEntity<>(projectStatusService.getCompanyProjectStatuses(projectId, excludeAttachments), HttpStatus.OK);
  }

  @GetMapping(value = "/objectCategoryCompanyStatus/{objectCategoryId}")
  public ResponseEntity<List<ProjectStatusType>> getCompanyProjectStatusesByObjectCategory(@PathVariable Long objectCategoryId){
    return new ResponseEntity<>(projectStatusService.getCompanyProjectStatusesByObjectCategory(objectCategoryId),HttpStatus.OK);
  }

  @GetMapping(value = "/companyStatus/{id}")
  public Optional<ProjectStatusType> getCompanyProjectStatusById(
    @PathVariable Long id) {
    return projectStatusService.getOneCompanyProjectStatusType(id);
  }
// end company project status type stuff

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

  @PostMapping(value = "/{projectId}/pushToMarketo")
  public ResponseEntity<Void> pushProjectToMarketo(@PathVariable Long projectId) {
    MarketoProject project = marketoService.getProject(projectId);

    if (project == null) {
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    Map<String, Object> lead = marketoService.projectToLead(project);
    marketoService.pushData(List.of(lead));

    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @Data
  public static class ProcessStepEventData {
    private String actionName, eventName, processStepName;
  }
  
	/**
	 * @param projectId
	 * @param query
	 * @param pageable
	 * @return
	 */
	@GetMapping(value = "/childProject")
	public Optional<Project> getChildProject(@RequestParam Long projectId, @RequestParam String query,
			Pageable pageable) {
		return projectService.getChildProjectDetails(projectId, query, pageable);
	}
}
