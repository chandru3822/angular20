package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.AttachmentTypeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/attachmentType")
public class AttachmentTypeController {

  @Autowired
  private AttachmentTypeService attachmentTypeService;

  @GetMapping(value = "/types", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getAttachmentTypes () {
    return attachmentTypeService.getAttachmentTypesForCompany();
  }

  @GetMapping(value = "/system", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getSystemAttachmentTypes () {
    return attachmentTypeService.getSystemAttachmentTypes();
  }

  @PutMapping(value = "/updateOrderInProcessStep", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateOrderInProcessStep(@RequestBody List<ProcessStepAttachmentType> attachmentTypes) {
    attachmentTypeService.updateOrderInProcessStep(attachmentTypes);
  }

  @PutMapping(value = "/updateOrderInProject", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateOrderInProject(@RequestBody List<ProjectAttachmentType> attachmentTypes) {
    attachmentTypeService.updateOrderInProject(attachmentTypes);
  }

  @PutMapping(value = "/updateReadOnly", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateReadOnly(@RequestBody ProjectAttachmentType projectAttachmentType) {
    attachmentTypeService.updateReadOnly(projectAttachmentType);
  }

  @GetMapping(value = "/typesForObjectType/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getAvailableTypesForObjectType (@PathVariable Long id) {
    return attachmentTypeService.getAvailableTypesForObjectType(id);
  }

  @GetMapping(value = "/objectTypes/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getObjectTypes(@PathVariable Long id) {
    return attachmentTypeService.getObjectTypes(id);
  }

  @GetMapping(value = "/objectTypes/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getObjectTypesForUserByCompany(@RequestParam Long companyId) {
    return attachmentTypeService.getObjectTypesByCompany(ObjectType.USER.id, companyId);
  }

  @GetMapping(value = "/objectTypes/contact", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getObjectTypesForContactByCompany(@RequestParam Long companyId) {
    return attachmentTypeService.getObjectTypesByCompany(ObjectType.CONTACT.id, companyId);
  }

  @GetMapping(value = "/objectTypes/org", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getObjectTypesForOrgByCompany(@RequestParam Long companyId) {
    return attachmentTypeService.getObjectTypesByCompany(ObjectType.ORGANIZATION.id, companyId);
  }

  @PutMapping(value = "/updateOrderInObjectType", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateOrderObjectType(@RequestBody List<ObjectTypeAttachmentType> attachmentTypes) {
    attachmentTypeService.updateOrderInObjectType(attachmentTypes);
  }

  @DeleteMapping(value = "/objectType/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteObjectType(@PathVariable Long id) {
    attachmentTypeService.deleteObjectType(id);
  }

  @PostMapping(value = "/objectType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> insertObjectType(@RequestBody ObjectTypeAttachmentType attachmentType) {
    return attachmentTypeService.insertObjectType(attachmentType);
  }

  @GetMapping(value = "/typesForStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getAvailableTypesForStep (@PathVariable Long id) {
    return attachmentTypeService.getAvailableTypesForProcessStep(id);
  }

  @GetMapping(value = "/typesForProjects", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getAttachmentTypesForProject () {
    return attachmentTypeService.getAttachmentTypesForProject();
  }

  @DeleteMapping(value = "/processStepType/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProcessStepType(@PathVariable Long id) {
    attachmentTypeService.deleteProcessStepType(id);
  }

  //this loads by processStepId
  @GetMapping(value = "/processStepTypes/{processStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProcessStepAttachmentType>> getProcessStepTypes(@PathVariable Long processStepId) {
    return new ResponseEntity<>(attachmentTypeService.getProcessStepTypes(processStepId), HttpStatus.OK);
  }

  //this loads by projectProcessStepId - we include projectId so we can verify that the request is valid
  @GetMapping(value = "/project/{projectId}/processStepTypes/{ppsId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProcessStepAttachmentType>> getProcessStepTypesByPps(@PathVariable Long projectId,
                                                                                  @PathVariable Long ppsId) {
    return new ResponseEntity<>(attachmentTypeService.getProcessStepTypesByPps(projectId, ppsId), HttpStatus.OK);
  }

  @PostMapping(value = "/processStepType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepAttachmentType> insertProcessStepType(@RequestBody ProcessStepAttachmentType attachmentType) {
    return attachmentTypeService.insertProcessStepType(attachmentType);
  }

  @DeleteMapping(value = "/projectType/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProjectType(@PathVariable Long id) {
    attachmentTypeService.deleteProjectType(id);
  }

  @PostMapping(value = "/projectType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProjectAttachmentType> insertProjectType(@RequestBody ProjectAttachmentType attachmentType) {
    return attachmentTypeService.insertProjectType(attachmentType);
  }

  @GetMapping(value = "/projectTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProjectAttachmentType> getProjectTypes(@RequestParam(required = false) Long projectId) {
    return attachmentTypeService.getProjectTypes(projectId);
  }

  @DeleteMapping(value = "/type/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    attachmentTypeService.deleteType(typeId);
  }

  @PutMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateType(@RequestBody AttachmentType type) {
    attachmentTypeService.updateType(type);
  }

  @PostMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<AttachmentType> insertType(@RequestBody AttachmentType type) {
    return attachmentTypeService.insertType(type);
  }

  //event types
  @GetMapping(value = "/eventTypes/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventAttachmentType>> getEventTypes(@PathVariable Long eventId) {
    return new ResponseEntity<>(attachmentTypeService.getEventTypes(eventId), HttpStatus.OK);
  }

  @GetMapping(value = "/eventTypesByPpsEventId/{ppsEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventAttachmentType>> getEventTypesByPpsEventId(@PathVariable Long ppsEventId) {
    return new ResponseEntity<>(attachmentTypeService.getEventTypesByPpsEventId(ppsEventId), HttpStatus.OK);
  }

  @GetMapping(value = "/project/{projectId}/pps/{ppsId}/eventTypesByPpsEventId/{ppsEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventAttachmentType>> getEventTypesByPpsEventIdAndPps(@PathVariable Long projectId,
                                                                                   @PathVariable Long ppsId,
                                                                                   @PathVariable Long ppsEventId) {
    return new ResponseEntity<>(attachmentTypeService.getEventTypesByPpsEventIdAndPps(projectId, ppsId, ppsEventId), HttpStatus.OK);
  }

  @GetMapping(value = "/eventAndPsTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventAttachmentType>> getEventAndPsTypes(@RequestParam Long psId,
                                                                      @RequestParam Long eventId) {
    return new ResponseEntity<>(attachmentTypeService.getEventAndPsTypes(psId, eventId), HttpStatus.OK);
  }

  @GetMapping(value = "/eventAndPsTypes/{ppsEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventAttachmentType>> getEventAndPsTypesByPpsEventId(@PathVariable Long ppsEventId) {
    return new ResponseEntity<>(attachmentTypeService.getEventAndPsTypesByPpsEventId(ppsEventId), HttpStatus.OK);
  }

  @PostMapping(value = "/eventType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<EventAttachmentType> insertEventType(@RequestBody EventAttachmentType attachmentType) {
    return attachmentTypeService.insertEventType(attachmentType);
  }

  @GetMapping(value = "/typesForEvent/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getAvailableTypesForEvent (@PathVariable Long id) {
    return attachmentTypeService.getAvailableTypesForEvent(id);
  }

  @DeleteMapping(value = "/eventType/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteEventType(@PathVariable Long id) {
    attachmentTypeService.deleteEventType(id);
  }
}
