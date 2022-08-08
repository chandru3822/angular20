package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.FieldInUse;
import com.albatross.api.v1.flow.model.ObjectTypeAttachmentType;
import com.albatross.api.v1.flow.model.event.EventAttachmentType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAttachmentType;
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

  @DeleteMapping(value = "/delete/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<FieldInUse>> deleteType(@PathVariable Long typeId) {
    return attachmentTypeService.deleteType(typeId);
  }

  @PutMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateType(@RequestBody AttachmentType type) {
    attachmentTypeService.updateType(type);
  }

  @PostMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<AttachmentType> insertType(@RequestBody AttachmentType type) {
    return attachmentTypeService.insertType(type);
  }

  @GetMapping(value = "/type/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<AttachmentType> getType(@PathVariable Long id) {
    return attachmentTypeService.getType(id);
  }

  //endpoints for displaying attachment types for uploading to (non-admin side)
  @GetMapping(value = "/processStepTypes/{ppsId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<ProcessStepAttachmentType>> getProcessStepTypesByPps(@PathVariable Long ppsId,
                                                                                  @RequestParam Boolean allowUpload,
                                                                                  @RequestParam Boolean focused,
                                                                                  @RequestParam Boolean linkable) {
    return new ResponseEntity<>(attachmentTypeService.getProcessStepTypesByPps(ppsId, allowUpload, focused, linkable), HttpStatus.OK);
  }

  @GetMapping(value = "/eventTypesByPpsEventId/{ppsEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<EventAttachmentType>> getEventTypesByPpsEventId(@PathVariable Long ppsEventId,
                                                                             @RequestParam Boolean allowUpload,
                                                                             @RequestParam Boolean focused,
                                                                             @RequestParam Boolean linkable) {
    return new ResponseEntity<>(attachmentTypeService.getEventTypesByPpsEventId(ppsEventId, allowUpload, focused, linkable), HttpStatus.OK);
  }

  //these endpoints are for the admin side of things
  //CONTACT
  @GetMapping(value = "/contact", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getTypesForContact() {
    return attachmentTypeService.getTypes(ObjectType.CONTACT, null);
  }

  @GetMapping(value = "/{attachmentTypeId}/contact", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForContact(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.CONTACT);
  }

  @GetMapping(value = "/contact/available", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAvailableTypesForContact() {
    return attachmentTypeService.getAvailableTypes(ObjectType.CONTACT, null);
  }

  @PostMapping(value = "/contact", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> addTypeForContact(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.CONTACT);
  }

  @PutMapping(value = "/contact/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeOrderForContact(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.CONTACT);
  }

  @PutMapping(value = "/contact/update", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeForContact(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.CONTACT);
  }

  @DeleteMapping(value = "/contact/{attachmentTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTypeForContact(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.CONTACT);
  }

  //ORGANIZATION
  @GetMapping(value = "/organization", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getTypesForOrg() {
    return attachmentTypeService.getTypes(ObjectType.ORGANIZATION, null);
  }

  @GetMapping(value = "/{attachmentTypeId}/organization", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForOrg(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.ORGANIZATION);
  }

  @GetMapping(value = "/organization/available", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAvailableTypesForOrg() {
    return attachmentTypeService.getAvailableTypes(ObjectType.ORGANIZATION, null);
  }

  @PostMapping(value = "/organization", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> addTypeForOrg(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.ORGANIZATION);
  }

  @PutMapping(value = "/organization/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeOrderForOrg(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.ORGANIZATION);
  }

  @PutMapping(value = "/organization/update", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeForOrg(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.ORGANIZATION);
  }

  @DeleteMapping(value = "/organization/{attachmentTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTypeForOrg(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.ORGANIZATION);
  }

  //USER
  @GetMapping(value = "/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getTypesForUser() {
    return attachmentTypeService.getTypes(ObjectType.USER, null);
  }

  @GetMapping(value = "/{attachmentTypeId}/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForUser(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.USER);
  }

  @GetMapping(value = "/user/available", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAvailableTypesForUser() {
    return attachmentTypeService.getAvailableTypes(ObjectType.USER, null);
  }

  @PostMapping(value = "/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> addTypeForUser(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.USER);
  }

  @PutMapping(value = "/user/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeOrderForUser(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.USER);
  }

  @PutMapping(value = "/user/update", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeForUser(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.USER);
  }

  @DeleteMapping(value = "/user/{attachmentTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTypeForUser(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.USER);
  }

  //PROJECT
  @GetMapping(value = "/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getTypesForProject() {
    return attachmentTypeService.getTypes(ObjectType.PROJECT, null);
  }

  @GetMapping(value = "/{attachmentTypeId}/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForProject(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.PROJECT);
  }

  @GetMapping(value = "/project/available", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAvailableTypesForProject() {
    return attachmentTypeService.getAvailableTypes(ObjectType.PROJECT, null);
  }

  @PostMapping(value = "/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> addTypeForProject(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.PROJECT);
  }

  @PutMapping(value = "/project/update", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeForProject(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.PROJECT);
  }

  @PutMapping(value = "/project/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeOrderForProject(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.PROJECT);
  }

  @DeleteMapping(value = "/project/{attachmentTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTypeForProject(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.PROJECT);
  }

  @PutMapping(value = "/project/updateReadOnly", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateReadOnly(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    attachmentTypeService.updateReadOnly(objectTypeAttachmentType, ObjectType.PROJECT);
  }

  //EVENT
  @GetMapping(value = "/event/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getTypesForEvent(@PathVariable Long eventId) {
    return attachmentTypeService.getTypes(ObjectType.EVENT, eventId);
  }

  @GetMapping(value = "/{attachmentTypeId}/event", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> getAttachmentTypeForEvent(@PathVariable Long attachmentTypeId) {
    return attachmentTypeService.getAttachmentType(attachmentTypeId, ObjectType.EVENT);
  }

  @GetMapping(value = "/event/{eventId}/available", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAvailableTypesForEvent(@PathVariable Long eventId) {
    return attachmentTypeService.getAvailableTypes(ObjectType.EVENT, eventId);
  }

  @PostMapping(value = "/event", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ObjectTypeAttachmentType> addTypeForEvent(@RequestBody ObjectTypeAttachmentType objectTypeAttachmentType) {
    return attachmentTypeService.addType(objectTypeAttachmentType, ObjectType.EVENT);
  }

  @PutMapping(value = "/event/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeOrderForEvent(@RequestBody List<ObjectTypeAttachmentType> types) {
    attachmentTypeService.updateTypeOrder(types, ObjectType.EVENT);
  }

  @PutMapping(value = "/event/update", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateTypeForEvent(@RequestBody ObjectTypeAttachmentType type) {
    attachmentTypeService.updateType(type, ObjectType.EVENT);
  }

  @DeleteMapping(value = "/event/{attachmentTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTypeForEvent(@PathVariable Long attachmentTypeId) {
    attachmentTypeService.deleteTypeForObjectType(attachmentTypeId, ObjectType.EVENT);
  }

  //these endpoints are for the non-admin side of things
  @GetMapping(value = "/combined/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getCombinedTypesForProject() {
    return attachmentTypeService.getCombinedTypesForProject();
  }

  @GetMapping(value = "/objectType/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAssignedTypesForProject(@RequestParam Boolean allowUpload,
                                                                   @RequestParam Boolean focused,
                                                                   @RequestParam Boolean linkable) {
    return attachmentTypeService.getAssignedTypes(ObjectType.PROJECT, allowUpload, focused, linkable);
  }

  @GetMapping(value = "/objectType/contact", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAssignedTypesForContact(@RequestParam Boolean allowUpload,
                                                                   @RequestParam Boolean focused,
                                                                   @RequestParam Boolean linkable) {
    return attachmentTypeService.getAssignedTypes(ObjectType.CONTACT, allowUpload, focused, linkable);
  }

  @GetMapping(value = "/objectType/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAssignedTypesForUser(@RequestParam Boolean allowUpload,
                                                                @RequestParam Boolean focused,
                                                                @RequestParam Boolean linkable) {
    return attachmentTypeService.getAssignedTypes(ObjectType.USER, allowUpload, focused, linkable);
  }

  @GetMapping(value = "/objectType/org", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeAttachmentType> getAssignedTypesForOrg(@RequestParam Boolean allowUpload,
                                                               @RequestParam Boolean focused,
                                                               @RequestParam Boolean linkable) {
    return attachmentTypeService.getAssignedTypes(ObjectType.ORGANIZATION, allowUpload, focused, linkable);
  }

}
