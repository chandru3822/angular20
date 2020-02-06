package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.ProjectProcessStep;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import com.albatross.api.v1.flow.services.ProjectService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import lombok.RequiredArgsConstructor;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.List;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/projectProcessStep")
public class ProjectProcessStepController {

  private final ProjectService projectService;

  private final ProjectProcessStepService projectProcessStepService;

  @GetMapping(value = "/{projectProcessStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ProjectProcessStep> getProjectProcessStepById(@PathVariable Long projectProcessStepId) {

    return new ResponseEntity<>(projectService.getProjectProcessStep(projectProcessStepId), HttpStatus.OK);
  }

  @GetMapping(value = "/{projectProcessStepId}/actionResult/{actionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<String> getActionResult(@PathVariable Long projectProcessStepId, @PathVariable Long actionId) {
    try {
      boolean canPerform = projectService.canPerformAction(actionId, projectProcessStepId);
      return new ResponseEntity<>(String.format("{\"canPerform\": %s}", canPerform), HttpStatus.OK);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }
  @PostMapping(value = "/{projectProcessStepId}/action/{actionId}")
  public ResponseEntity<Void> performAction(@PathVariable Long projectProcessStepId, @PathVariable Long actionId) {
    try {
      boolean canPerform = projectService.canPerformAction(actionId, projectProcessStepId);
      if (!canPerform) {
        //@TODO: Better error here
        throw new RuntimeException("Can't do it");
      }
      projectService.performAction(actionId, projectProcessStepId);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProjectProcessStep saveProjectProcessStep(@RequestBody ProjectProcessStep pps) {
    return projectService.saveProjectProcessStep(pps);
  }

  @GetMapping(value = "/{projectProcessStepId}/attachments", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Attachment>> getProjectProcessStepAttachments(@PathVariable Long projectProcessStepId) {
    return new ResponseEntity<>(projectService.getProjectProcessStepAttachments(projectProcessStepId), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectProcessStepId}/attachment", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Attachment> uploadProjectProcessStepAttachment(@PathVariable Long projectProcessStepId,
                                                                       @RequestParam Long attachmentTypeId,
                                                                       @RequestParam("file")MultipartFile file) throws IOException {
    return new ResponseEntity<>(projectProcessStepService.addAttachment(file, projectProcessStepId, attachmentTypeId), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectProcessStepId}/owner")
  public ResponseEntity<Void> updateProjectProcessStepOwner(@PathVariable Long projectProcessStepId, @RequestBody Owner owner) {
    projectProcessStepService.updateOwner(projectProcessStepId, owner);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }
}
