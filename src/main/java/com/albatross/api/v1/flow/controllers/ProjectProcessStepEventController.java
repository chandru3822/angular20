package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.CompanyEventStatusType;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.services.ProjectProcessStepEventService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/projectProcessStep/{ppsId}/event")
public class ProjectProcessStepEventController {

  private final ProjectProcessStepEventService projectProcessStepEventService;

  @PostMapping(value = "/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProjectProcessStepEvent> insertPpsEvent(@PathVariable Long ppsId,
                                                          @PathVariable Long eventId) throws Exception {
    return projectProcessStepEventService.insertPpsEvent(ppsId, eventId);
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

  @GetMapping(value = "/{eventId}/cancelledAssigned", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyEventStatusType> getCancelledAssignedToPpsEvent(@PathVariable Long eventId) {
    return projectProcessStepEventService.getCancelledAssignedToPpsEvent(eventId);
  }

  @PutMapping(value = "/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProjectProcessStepEvent> savePpsEventDetails(@PathVariable Long eventId,
                                                               @RequestBody SaveEventRequest saveEvent) throws Exception {
    return projectProcessStepEventService.savePpsEventDetails(eventId, saveEvent);
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
  @Transactional
  @PostMapping(value = "/{eventId}/action/{actionId}/perform", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Object> performStepEventAction(@PathVariable Long ppsId,
                                                       @PathVariable Long eventId,
                                                       @PathVariable Long actionId,
                                                       @RequestBody SaveEventRequest saveEvent) throws Exception {
    //save the custom field values and default values
    projectProcessStepEventService.savePpsEventDetails(eventId, saveEvent);

    //do the action
    return projectProcessStepEventService.performStepEventAction(ppsId, eventId, actionId);
  }

  @PostMapping(value = "/{eventId}/status", consumes = MediaType.APPLICATION_JSON_VALUE)
  public void updateProjectProcessStepEventStatus(@PathVariable Long ppsId,
                                                                  @PathVariable Long eventId,
                                                                  @RequestBody CompanyEventStatusType status) throws Exception {
    projectProcessStepEventService.setStatus(eventId, status.getId());
  }

  @Data
  public static class SaveEventRequest {
    private Long id, resourceId, companyEventStatusTypeId, saveVersion;
    private Timestamp startTime, endTime;
    private List<CustomFieldValue> customFieldValues;
  }

}
