package com.albatross.api.v1.flow.controllers;

import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.ProjectTagMessage;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.CompanyEventStatusType;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.services.ProjectProcessStepEventService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(
  value = "/api/v1/flow/projectProcessStep/{ppsId}/event",
  produces = MediaType.APPLICATION_JSON_VALUE)
public class ProjectProcessStepEventController {

  private final ProjectProcessStepEventService projectProcessStepEventService;
  private final PubSubService pubSubService;

  @PostMapping(value = "/{eventId}")
  public Optional<ProjectProcessStepEvent> insertPpsEvent(
    @PathVariable Long ppsId, @PathVariable Long eventId) throws Exception {
    return projectProcessStepEventService.insertPpsEvent(ppsId, eventId);
  }

  @GetMapping(value = "/{eventId}")
  public Optional<ProjectProcessStepEvent> getPpsEvent(
    @PathVariable Long ppsId, @PathVariable Long eventId) throws Exception {
    return projectProcessStepEventService.getPpsEvent(ppsId, eventId);
  }

  @DeleteMapping(value = "/{eventId}")
  public void deletePpsEvent(@PathVariable Long eventId) {
    projectProcessStepEventService.deletePpsEvent(eventId);
  }

  @GetMapping(value = "/{eventId}/cancelledAssigned")
  public List<CompanyEventStatusType> getCancelledAssignedToPpsEvent(@PathVariable Long eventId) {
    return projectProcessStepEventService.getCancelledAssignedToPpsEvent(eventId);
  }

  @PutMapping(value = "/{eventId}")
  public Optional<ProjectProcessStepEvent> savePpsEventDetails(
    @PathVariable Long ppsId, @PathVariable Long eventId, @RequestBody SaveEventRequest saveEvent)
    throws Exception {
    return projectProcessStepEventService.savePpsEventDetails(ppsId, eventId, saveEvent);
  }

  @GetMapping(
    value = "/{projectProcessStepEventId}/attachments",
    produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Attachment>> getProjectProcessStepEventAttachments(
    @PathVariable Long projectProcessStepEventId,
    @RequestParam(required = false) Boolean isMobile,
    @RequestParam(required = false) Boolean linked) {
    return new ResponseEntity<>(
      projectProcessStepEventService.getProjectProcessStepEventAttachments(
        projectProcessStepEventId, isMobile, linked),
      HttpStatus.OK);
  }

  @PostMapping(value = "/{projectProcessStepEventId}/linkAttachment/{attachmentId}")
  public void linkAttachment(@PathVariable Long projectProcessStepEventId,
                             @PathVariable Long attachmentId,
                             @RequestParam Boolean doLink) {
    //used to link or unlink
    projectProcessStepEventService.linkAttachment(projectProcessStepEventId, attachmentId, doLink);
  }

  @PostMapping(
    value = "/{projectProcessStepEventId}/attachment",
    produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Attachment> uploadProjectProcessStepEventAttachment(
    @PathVariable Long projectProcessStepEventId,
    @RequestParam Long attachmentTypeId,
    @RequestParam String displayName,
    @RequestParam("file") MultipartFile file)
    throws IOException {
    return new ResponseEntity<>(
      projectProcessStepEventService.addAttachment(
        file, projectProcessStepEventId, attachmentTypeId, displayName),
      HttpStatus.OK);
  }

  // action

  @PostMapping(
    value = "/{eventId}/action/{actionId}/perform",
    produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Object> performStepEventAction(
    @PathVariable Long ppsId,
    @PathVariable Long eventId,
    @PathVariable Long actionId,
    @RequestBody SaveEventRequest saveEvent) {
    try {
      // save the custom field values and default values
      projectProcessStepEventService.savePpsEventDetails(ppsId, eventId, saveEvent);

      // do the action
      ProjectProcessStepEventService.PpseActionResult ppseActionResult = projectProcessStepEventService.performStepEventAction(ppsId, eventId, actionId);

      if (ppseActionResult.getShouldRunProjectTagUpdate().get()) {
        //todo: when tags are assigned/removed without using actions, remove this and move it to the new place
        ProjectTagMessage ptm = new ProjectTagMessage();
        ptm.setProjectId(ppseActionResult.getProjectId());
        pubSubService.publish(EventChannel.NOTIFICATION, ptm);
      }

      return ResponseEntity.ok(getPpsEvent(ppsId, ppseActionResult.getPpsEventId()));
    } catch (Exception e) {
      final String errMessage =
        String.format(
          "PPSE: Unable to MANUALLY trigger action ID: %s, PPS EVENT ID: %s *** %s",
          actionId, eventId, e.getMessage());
      log.error(errMessage);
      throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
    }
  }

  @PostMapping(value = "/{eventId}/status")
  public void updateProjectProcessStepEventStatus(
    @PathVariable Long ppsId,
    @PathVariable Long eventId,
    @RequestBody CompanyEventStatusType status)
    throws Exception {
    projectProcessStepEventService.setStatus(ppsId, eventId, status.getId());
  }

  @Data
  public static class SaveEventRequest {
    private Long id, resourceId, companyEventStatusTypeId, saveVersion;
    private Timestamp startTime, endTime;
    private List<CustomFieldValue> customFieldValues;
  }
}
