package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.services.ProjectProcessStepEventService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
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
@RequestMapping(value = "/api/v1/flow/projectProcessStep/{ppsId}/event")
public class ProjectProcessStepEventController {

  private final ProjectProcessStepEventService projectProcessStepEventService;

  @PostMapping(value = "/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProjectProcessStepEvent> insertPpsEvent(@PathVariable Long ppsId,
                                                          @PathVariable Long processStepEventId) throws Exception {
    return projectProcessStepEventService.insertPpsEvent(ppsId, processStepEventId);
  }

  @GetMapping(value = "/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProjectProcessStepEvent> getPpsEvent(@PathVariable Long ppsId,
                                                       @PathVariable Long eventId) throws Exception {
    return projectProcessStepEventService.getPpsEvent(eventId);
  }

  @DeleteMapping(value = "/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePpsEvent(@PathVariable Long eventId) {
    projectProcessStepEventService.deletePpsEvent(eventId);
  }

  @PutMapping(value = "/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProjectProcessStepEvent> savePpsEventDetails(@PathVariable Long eventId,
                                                               @RequestBody ProjectProcessStepEvent ppsEvent) throws Exception {
    return projectProcessStepEventService.savePpsEventDetails(eventId, ppsEvent);
  }

  @GetMapping(value = "/{projectProcessStepEventId}/attachments", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Attachment>> getProjectProcessStepEventAttachments(@PathVariable Long projectProcessStepEventId,
                                                                                @PathVariable(required = false) Boolean isMobile) {
    return new ResponseEntity<>(projectProcessStepEventService.getProjectProcessStepEventAttachments(projectProcessStepEventId, isMobile), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectProcessStepEventId}/attachment", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Attachment> uploadProjectProcessStepEventAttachment(@PathVariable Long projectProcessStepEventId,
                                                                            @RequestParam Long attachmentTypeId,
                                                                            @RequestParam("file") MultipartFile file) throws IOException {
    return new ResponseEntity<>(projectProcessStepEventService.addAttachment(file, projectProcessStepEventId, attachmentTypeId), HttpStatus.OK);
  }

  //action
  @PostMapping(value = "/{eventId}/action/{actionId}/perform", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Object> performStepEventAction (@PathVariable Long ppsId,
                                                        @PathVariable Long eventId,
                                                        @PathVariable Long actionId,
                                                        @RequestBody ProjectProcessStepEvent ppsEvent) throws Exception {
    //save the custom field values
    projectProcessStepEventService.savePpsEventDetails(eventId, ppsEvent);

    //do the action
    return projectProcessStepEventService.performStepEventAction(ppsId, eventId, actionId);
  }

}
