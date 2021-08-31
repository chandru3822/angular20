package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.ProjectProcessStepRequirementService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/projectProcessStep")
public class ProjectProcessStepController {

  private final ProjectProcessStepService projectProcessStepService;

  private final ProjectProcessStepRequirementService projectProcessStepRequirementService;

  @GetMapping(value = "/{projectProcessStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ProjectProcessStep> getProjectProcessStepById(@PathVariable Long projectProcessStepId) {
    try {
      ProjectProcessStep pps = projectProcessStepService.getProjectProcessStep(projectProcessStepId);

      int index = 0;
      for (ProjectProcessStepAction a : pps.getActions()) {
        pps.getActions().set(index, projectProcessStepService.getActionResult(a.getId(), projectProcessStepId));
        index++;
      }

      return new ResponseEntity<>(pps, HttpStatus.OK);
    } catch (Exception e) {
      final String errMessage = String.format("Unable to get PPS, PPS ID: %s *** %s", projectProcessStepId, e.getMessage());
      log.error(errMessage);
      e.printStackTrace();
      throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
    }
  }

  @DeleteMapping(value = "/{projectProcessStepId}")
  public ResponseEntity<Void> deleteProjectProcessStep(@PathVariable Long projectProcessStepId) {
    try {
        projectProcessStepService.deleteProjectProcessStep(projectProcessStepId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (Exception e) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping(value = "/{ppsId}/actionResult/{actionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ProjectProcessStepAction> getActionResult(@PathVariable Long ppsId, @PathVariable Long actionId) {
    try {
      return new ResponseEntity<>(projectProcessStepService.getActionResult(actionId, ppsId), HttpStatus.OK);
    } catch (Exception e) {
      final String errMessage = String.format("Unable to get action result, action ID: %s, PPS ID: %s *** %s", actionId, ppsId, e.getMessage());
      log.error(errMessage);
      e.printStackTrace();
      throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
    }
  }
  @PostMapping(value = "/{ppsId}/action/{actionId}")
  public ResponseEntity<Void> performAction(@PathVariable Long ppsId, @PathVariable Long actionId) {
    try {
      ProjectProcessStep pps = projectProcessStepService.getProjectProcessStep(ppsId);
      ProjectProcessStepAction action = pps.getActions().stream().filter(a -> a.getId().equals(actionId)).findFirst().orElse(null);

      if (pps.getProcessStepStatusTypeId() != 1 || action == null) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }

      List<Long> requirementIds = action.getProcessStepLogicList().stream()
          .filter(step -> step.getProcessStepRequirementId() != null)
          .map(ProcessStepLogic::getProcessStepRequirementId)
          .collect(Collectors.toList());
      List<ProjectProcessStepRequirement> requirements = projectProcessStepRequirementService.getByProjectProcessStepId(pps.getProjectProcessStepId(), requirementIds);
      ProjectProcessStepAction actionResult = projectProcessStepService.canPerformAction(action, pps, requirements);
      boolean canPerform = actionResult.getCanPerform();
      if (!canPerform) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      projectProcessStepService.performAction(action, pps);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (Exception e) {
      final String errMessage = String.format("PPS: Unable to MANUALLY trigger action ID: %s, PPS ID: %s *** %s",  actionId, ppsId, e.getMessage());
      log.error(errMessage);
      e.printStackTrace();
      throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
    }
  }

  @PostMapping(value = "/initialStatus/{initialCompanyProcessStepStatusTypeId}/existingStatus/{existingCompanyProcessStepStatusTypeId}", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Long> createProjectProcessStep(@PathVariable Long initialCompanyProcessStepStatusTypeId,
                                                       @PathVariable Long existingCompanyProcessStepStatusTypeId,
                                                       @RequestBody ProjectProcessStep projectProcessStep) {
    return new ResponseEntity<>(projectProcessStepService.insertProjectProcessStep(projectProcessStep.getProjectId(), projectProcessStep.getProcessStepId(), null, null, true, initialCompanyProcessStepStatusTypeId, existingCompanyProcessStepStatusTypeId, null), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectProcessStepId}/attachments", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Attachment>> getProjectProcessStepAttachments(@PathVariable Long projectProcessStepId,
                                                                           @PathVariable(required = false) Boolean isMobile) {
    return new ResponseEntity<>(projectProcessStepService.getProjectProcessStepAttachments(projectProcessStepId, isMobile), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectProcessStepId}/attachment", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Attachment> uploadProjectProcessStepAttachment(@PathVariable Long projectProcessStepId,
                                                                       @RequestParam Long attachmentTypeId,
                                                                       @RequestParam("file")MultipartFile file) throws IOException {
    return new ResponseEntity<>(projectProcessStepService.addAttachment(file, projectProcessStepId, attachmentTypeId), HttpStatus.OK);
  }

  @GetMapping(value = "/owners/{processStepProcessId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Owner>> getAvailableProjectProcessStepOwners(@PathVariable Long processStepProcessId) {
    return new ResponseEntity<>(projectProcessStepService.getOwners(processStepProcessId), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectProcessStepId}/owner")
  public ResponseEntity<Void> updateProjectProcessStepOwner(@PathVariable Long projectProcessStepId,
                                                            @RequestBody Owner owner) {
    projectProcessStepService.updateOwner(projectProcessStepId, owner, false);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @PostMapping(value = "/{projectProcessStepId}/owner/checkExisting")
  public ResponseEntity updateProjectProcessStepOwnerCheckExisting(@PathVariable Long projectProcessStepId,
                                                                         @RequestBody Owner owner) {
    return projectProcessStepService.updateOwner(projectProcessStepId, owner, true);
  }

  @PostMapping(value = "/{projectProcessStepId}/status", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateProjectProcessStepStatus(@PathVariable Long projectProcessStepId, @RequestBody CompanyProcessStepStatusType status) {
    try {
        projectProcessStepService.setStatus(projectProcessStepId, status.getProcessStepStatusTypeId(), status.getId(), true, status.getCancelledCompanyProcessStepStatusTypeId(), null);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (RuntimeException e) {
        throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }

  @PostMapping(value = "/{ppsId}/main")
  public ResponseEntity<Void> updateMainProjectProcessStep(@PathVariable Long ppsId, @RequestBody CompanyProcessStepStatusType status) {
    try {
      projectProcessStepService.setMain(ppsId, status);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (RuntimeException e) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }
}
