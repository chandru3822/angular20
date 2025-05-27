package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.services.ProjectProcessStepEventService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.graalvm.shadowed.org.jcodings.util.Hash;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
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
  private final SecurityService securityService;

    @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<ProjectProcessStepEvent>> getPpsEventsById(@PathVariable Long ppsId) {
        return new ResponseEntity<>(projectProcessStepEventService.getByPpsId(ppsId), HttpStatus.OK);
    }

  @PostMapping(value = "/{eventId}")
  public Optional<ProjectProcessStepEvent> insertPpsEvent(
    @PathVariable Long ppsId, @PathVariable Long eventId) throws Exception {
    return projectProcessStepEventService.insertPpsEvent(ppsId, eventId);
  }

  @GetMapping(value="/{eventId}/{actionId}")
  public ResponseEntity<Object> getProjectProcessStepEventActionRequirement(@PathVariable Long ppsId,@PathVariable Long eventId,
                                                                       @PathVariable Long actionId) throws Exception {
    HashMap<String, Object> response = new HashMap<>();
    HashMap<Long, Boolean> ppsEventActionRequirementsPassedDetails = projectProcessStepEventService.getPpsEventActionRequirementsPassedDetails(ppsId, eventId, actionId);
    response.put("content",ppsEventActionRequirementsPassedDetails);
    return new ResponseEntity<>(response,HttpStatus.OK);
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

  @PutMapping(value = "/{eventId}/{forceSave}")
  public ResponseEntity<Object> savePpsEventDetails(
    @PathVariable Long ppsId, @PathVariable Long eventId, @RequestBody SaveEventRequest saveEvent, @PathVariable Optional<Boolean> forceSave)
    throws Exception {
    if (forceSave.isPresent() && !forceSave.get()) {
      List<ScheduleEvent> conflictList = projectProcessStepEventService.checkForSchedulingConflict(saveEvent, ppsId);
      if (conflictList != null && !conflictList.isEmpty()) {
        return new ResponseEntity<>(conflictList, HttpStatus.CONFLICT);
      }
    }
    return ResponseEntity.ok(projectProcessStepEventService.savePpsEventDetails(ppsId, eventId, saveEvent));
  }

  @GetMapping(value = "/{projectProcessStepEventId}/attachments")
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

  @PostMapping(value = "/{projectProcessStepEventId}/attachment")
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

  @PostMapping(value = "/{projectProcessStepEventId}/attachmentss")
  public ResponseEntity<List<Attachment>> uploadMultipleProjectProcessStepEventAttachment(
    @PathVariable Long projectProcessStepEventId,
    @RequestParam Long attachmentTypeId,
    @RequestParam("files") MultipartFile[] files)
    throws IOException {

    return new ResponseEntity<>(
      projectProcessStepEventService.addAttachments(files, projectProcessStepEventId, attachmentTypeId), HttpStatus.OK);
  }

  // action

  @PostMapping(value = "/{eventId}/action/{actionId}/perform")
  public ResponseEntity<Object> performStepEventAction(
    @PathVariable Long ppsId,
    @PathVariable Long eventId,
    @PathVariable Long actionId,
    @RequestBody SaveEventRequest saveEvent) {
    try {
        if (actionId == 1) {
            if (saveEvent.getForceSave() != null && !saveEvent.getForceSave()) {
                List<ScheduleEvent> conflictList = projectProcessStepEventService.checkForSchedulingConflict(saveEvent, ppsId);
                if (conflictList != null && !conflictList.isEmpty()) {
                    return new ResponseEntity<>(conflictList, HttpStatus.CONFLICT);
                }
            }
        }

        var ppsEvent = projectProcessStepEventService.performStepEventActionTransactional(ppsId, eventId, actionId, saveEvent, Boolean.FALSE);
        return ResponseEntity.ok(ppsEvent);
    } catch (Exception e) {
      User currentUser = securityService.getCurrentUser();
      final String errMessage =
          "PPSE: Unable to MANUALLY trigger action ID: %s, PPS EVENT ID: %s, BY USER: %s *** %s".formatted(
          actionId, eventId, currentUser.trueUserId(), e.getMessage());
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
    private Boolean forceSave;
  }
}
