package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import lombok.RequiredArgsConstructor;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import retrofit2.Response;

import java.io.IOException;
import java.util.List;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/projectProcessStep")
public class ProjectProcessStepController {

  private final ProjectProcessStepService projectProcessStepService;

  @GetMapping(value = "/{projectProcessStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ProjectProcessStep> getProjectProcessStepById(@PathVariable Long projectProcessStepId) {
    return new ResponseEntity<>(projectProcessStepService.getProjectProcessStep(projectProcessStepId), HttpStatus.OK);
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

  @GetMapping(value = "/{projectProcessStepId}/actionResult/{actionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<String> getActionResult(@PathVariable Long projectProcessStepId, @PathVariable Long actionId) {
    try {
      boolean canPerform = projectProcessStepService.canPerformAction(actionId, projectProcessStepId);
      return new ResponseEntity<>(String.format("{\"canPerform\": %s}", canPerform), HttpStatus.OK);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }
  @PostMapping(value = "/{projectProcessStepId}/action/{actionId}")
  public ResponseEntity<Void> performAction(@PathVariable Long projectProcessStepId, @PathVariable Long actionId) {
    try {
      boolean canPerform = projectProcessStepService.canPerformAction(actionId, projectProcessStepId);
      if (!canPerform) {
        //@TODO: Better error here
        throw new RuntimeException("Can't do it");
      }
      projectProcessStepService.performAction(actionId, projectProcessStepId);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }

  @PostMapping(value = "", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ProjectProcessStep> createProjectProcessStep(@RequestBody ProjectProcessStep projectProcessStep) {
    return new ResponseEntity<>(projectProcessStepService.insertProjectProcessStep(projectProcessStep.getProjectId(), projectProcessStep.getProcessStepId(), projectProcessStep.getCompanyProcessStepStatusTypeId(), null, projectProcessStep.getMain()), HttpStatus.OK);
  }

  @PutMapping(value = "", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CustomFieldGroup>> saveProjectProcessStep(@RequestBody ProjectProcessStep pps) {
    return new ResponseEntity<>(projectProcessStepService.saveProjectProcessStep(pps), HttpStatus.OK);
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
  public ResponseEntity<?> updateProjectProcessStepStatus(@PathVariable Long projectProcessStepId, @RequestBody CompanyProcessStepStatusType status) {
    try {
        projectProcessStepService.setStatus(projectProcessStepId, status.getProcessStepStatusTypeId(), status.getId());
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (RuntimeException e) {
        return new ResponseEntity<>(e.getMessage(), HttpStatus.CONFLICT);
    }
  }

    @PutMapping(value = "/{projectProcessStepId}/main")
    public ResponseEntity<Void> updateProjectProcessStepMain(@PathVariable Long projectProcessStepId) {
        try {
            projectProcessStepService.updateMain(projectProcessStepId);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
  }
}
