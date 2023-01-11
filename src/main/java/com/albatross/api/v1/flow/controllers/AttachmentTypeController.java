package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.FieldInUse;
import com.albatross.api.v1.flow.model.ObjectTypeAttachmentType;
import com.albatross.api.v1.flow.model.event.EventAttachmentType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAttachmentType;
import com.albatross.api.v1.flow.services.AttachmentTypeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
@RequestMapping(value = "/api/v1/flow/attachmentType", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class AttachmentTypeController {

  private final AttachmentTypeService attachmentTypeService;

  @GetMapping(value = "/types")
  public List<AttachmentType> getAttachmentTypes() {
    return attachmentTypeService.getAttachmentTypesForCompany();
  }

  @GetMapping(value = "/system")
  public List<AttachmentType> getSystemAttachmentTypes() {
    return attachmentTypeService.getSystemAttachmentTypes();
  }

  @DeleteMapping(value = "/delete/{typeId}")
  public ResponseEntity<List<FieldInUse>> deleteType(@PathVariable Long typeId) {
    return attachmentTypeService.deleteType(typeId);
  }

  @PutMapping(value = "/type")
  public void updateType(@RequestBody AttachmentType type) {
    attachmentTypeService.updateType(type);
  }

  @PostMapping(value = "/type")
  public Optional<AttachmentType> insertType(@RequestBody AttachmentType type) {
    return attachmentTypeService.insertType(type);
  }

  @GetMapping(value = "/type/{id}")
  public Optional<AttachmentType> getType(@PathVariable Long id) {
    return attachmentTypeService.getType(id);
  }

  //endpoints for displaying attachment types for uploading to (non-admin side)
  @GetMapping(value = "/processStepTypes/{ppsId}")
  public ResponseEntity<List<ProcessStepAttachmentType>> getProcessStepTypesByPps(@PathVariable Long ppsId,
                                                                                  @RequestParam Boolean allowUpload,
                                                                                  @RequestParam Boolean focused,
                                                                                  @RequestParam Boolean linkable) {
    return new ResponseEntity<>(attachmentTypeService.getProcessStepTypesByPps(ppsId, allowUpload, focused, linkable), HttpStatus.OK);
  }

  @GetMapping(value = "/eventTypesByPpsEventId/{ppsEventId}")
  public ResponseEntity<List<EventAttachmentType>> getEventTypesByPpsEventId(@PathVariable Long ppsEventId,
                                                                             @RequestParam Boolean allowUpload,
                                                                             @RequestParam Boolean focused,
                                                                             @RequestParam Boolean linkable) {
    return new ResponseEntity<>(attachmentTypeService.getEventTypesByPpsEventId(ppsEventId, allowUpload, focused, linkable), HttpStatus.OK);
  }

  //these endpoints are for the admin side of things
  //CONTACT
  @GetMapping(value = "/contact")
  public List<ObjectTypeAttachmentType> getTypesForContact() {
    return attachmentTypeService.getTypes(ObjectType.CONTACT, null);
  }

  @GetMapping(value = "/{attachmentTypeId}/contact")
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForContact(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.CONTACT);
  }

  @GetMapping(value = "/contact/available")
  public List<ObjectTypeAttachmentType> getAvailableTypesForContact() {
    return attachmentTypeService.getAvailableTypes(ObjectType.CONTACT, null);
  }

  @PostMapping(value = "/contact")
  public Optional<ObjectTypeAttachmentType> addTypeForContact(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.CONTACT);
  }

  @PutMapping(value = "/contact/order")
  public void updateTypeOrderForContact(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.CONTACT);
  }

  @PutMapping(value = "/contact/update")
  public void updateTypeForContact(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.CONTACT);
  }

  @DeleteMapping(value = "/contact/{attachmentTypeId}")
  public void deleteTypeForContact(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.CONTACT);
  }

  //ORGANIZATION
  @GetMapping(value = "/organization")
  public List<ObjectTypeAttachmentType> getTypesForOrg() {
    return attachmentTypeService.getTypes(ObjectType.ORGANIZATION, null);
  }

  @GetMapping(value = "/{attachmentTypeId}/organization")
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForOrg(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.ORGANIZATION);
  }

  @GetMapping(value = "/organization/available")
  public List<ObjectTypeAttachmentType> getAvailableTypesForOrg() {
    return attachmentTypeService.getAvailableTypes(ObjectType.ORGANIZATION, null);
  }

  @PostMapping(value = "/organization")
  public Optional<ObjectTypeAttachmentType> addTypeForOrg(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.ORGANIZATION);
  }

  @PutMapping(value = "/organization/order")
  public void updateTypeOrderForOrg(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.ORGANIZATION);
  }

  @PutMapping(value = "/organization/update")
  public void updateTypeForOrg(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.ORGANIZATION);
  }

  @DeleteMapping(value = "/organization/{attachmentTypeId}")
  public void deleteTypeForOrg(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.ORGANIZATION);
  }

  //USER
  @GetMapping(value = "/user")
  public List<ObjectTypeAttachmentType> getTypesForUser() {
    return attachmentTypeService.getTypes(ObjectType.USER, null);
  }

  @GetMapping(value = "/{attachmentTypeId}/user")
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForUser(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.USER);
  }

  @GetMapping(value = "/user/available")
  public List<ObjectTypeAttachmentType> getAvailableTypesForUser() {
    return attachmentTypeService.getAvailableTypes(ObjectType.USER, null);
  }

  @PostMapping(value = "/user")
  public Optional<ObjectTypeAttachmentType> addTypeForUser(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.USER);
  }

  @PutMapping(value = "/user/order")
  public void updateTypeOrderForUser(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.USER);
  }

  @PutMapping(value = "/user/update")
  public void updateTypeForUser(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.USER);
  }

  @DeleteMapping(value = "/user/{attachmentTypeId}")
  public void deleteTypeForUser(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.USER);
  }

  //PROJECT
  @GetMapping(value = "/project")
  public List<ObjectTypeAttachmentType> getTypesForProject() {
    return attachmentTypeService.getTypes(ObjectType.PROJECT, null);
  }

  @GetMapping(value = "/{attachmentTypeId}/project")
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForProject(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.PROJECT);
  }

  @GetMapping(value = "/project/available")
  public List<ObjectTypeAttachmentType> getAvailableTypesForProject() {
    return attachmentTypeService.getAvailableTypes(ObjectType.PROJECT, null);
  }

  @PostMapping(value = "/project")
  public Optional<ObjectTypeAttachmentType> addTypeForProject(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.PROJECT);
  }

  @PutMapping(value = "/project/update")
  public void updateTypeForProject(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.PROJECT);
  }

  @PutMapping(value = "/project/order")
  public void updateTypeOrderForProject(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.PROJECT);
  }

  @DeleteMapping(value = "/project/{attachmentTypeId}")
  public void deleteTypeForProject(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.PROJECT);
  }

  //EVENT
  @GetMapping(value = "/event/{eventId}")
  public List<ObjectTypeAttachmentType> getTypesForEvent(@PathVariable Long eventId) {
    return attachmentTypeService.getTypes(ObjectType.EVENT, eventId);
  }

  @GetMapping(value = "/{attachmentTypeId}/event")
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForEvent(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.EVENT);
  }

  @GetMapping(value = "/event/{eventId}/available")
  public List<ObjectTypeAttachmentType> getAvailableTypesForEvent(@PathVariable Long eventId) {
    return attachmentTypeService.getAvailableTypes(ObjectType.EVENT, eventId);
  }

  @PostMapping(value = "/event")
  public Optional<ObjectTypeAttachmentType> addTypeForEvent(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.EVENT);
  }

  @PutMapping(value = "/event/order")
  public void updateTypeOrderForEvent(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.EVENT);
  }

  @PutMapping(value = "/event/update")
  public void updateTypeForEvent(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.EVENT);
  }

  @DeleteMapping(value = "/event/{attachmentTypeId}")
  public void deleteTypeForEvent(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.EVENT);
  }

  //this endpoint is specifically for mobile. they want all attachment types back and they will parse them as needed
  @GetMapping(value = "/assigned")
  public List<ObjectTypeAttachmentType> getAssignedTypesToObject(@RequestParam(required = false) Long ppsId,
                                                                 @RequestParam(required = false) Long ppsEventId) {
    return attachmentTypeService.getAssignedTypesToObject(ppsId, ppsEventId);
  }

  //these endpoints are for the non-admin side of things
  @GetMapping(value = "/combined/project")
  public List<ObjectTypeAttachmentType> getCombinedTypesForProject(@RequestParam Boolean focused,
                                                                   @RequestParam(required = false) Long ppsId,
                                                                   @RequestParam(required = false) Long ppsEventId) {
    return attachmentTypeService.getCombinedTypesForProject(ppsId, ppsEventId, focused);
  }

  @GetMapping(value = "/objectType/project")
  public List<ObjectTypeAttachmentType> getAssignedTypesForProject(@RequestParam Boolean allowUpload,
                                                                   @RequestParam Boolean focused,
                                                                   @RequestParam Boolean linkable) {
    return attachmentTypeService.getAssignedTypes(ObjectType.PROJECT, allowUpload, focused, linkable);
  }

  @GetMapping(value = "/objectType/contact")
  public List<ObjectTypeAttachmentType> getAssignedTypesForContact(@RequestParam Boolean allowUpload,
                                                                   @RequestParam Boolean focused,
                                                                   @RequestParam Boolean linkable) {
    return attachmentTypeService.getAssignedTypes(ObjectType.CONTACT, allowUpload, focused, linkable);
  }

  @GetMapping(value = "/objectType/user")
  public List<ObjectTypeAttachmentType> getAssignedTypesForUser(@RequestParam Boolean allowUpload,
                                                                @RequestParam Boolean focused,
                                                                @RequestParam Boolean linkable) {
    return attachmentTypeService.getAssignedTypes(ObjectType.USER, allowUpload, focused, linkable);
  }

  @GetMapping(value = "/objectType/org")
  public List<ObjectTypeAttachmentType> getAssignedTypesForOrg(@RequestParam Boolean allowUpload,
                                                               @RequestParam Boolean focused,
                                                               @RequestParam Boolean linkable) {
    return attachmentTypeService.getAssignedTypes(ObjectType.ORGANIZATION, allowUpload, focused, linkable);
  }

}
