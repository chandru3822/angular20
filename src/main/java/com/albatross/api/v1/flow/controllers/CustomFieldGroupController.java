package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.CustomFieldGroupService;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/customFieldGroup")
public class CustomFieldGroupController {

  @Autowired
  private CustomFieldGroupService customFieldGroupService;

  @PostMapping(value = "/addFieldToGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomField addFieldToGroup (@RequestBody CustomField customField) {
    return customFieldGroupService.addFieldToGroup(customField);
  }

  @PostMapping(value = "/moveFieldToOtherGroup/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomField moveFieldToOtherGroup (@PathVariable Long id,
                                            @RequestBody CustomField customField) {
    return customFieldGroupService.moveFieldToOtherGroup(customField, id);
  }


  @DeleteMapping(value = "/deleteFieldFromGroup/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteFieldInGroup(@PathVariable Long id) {
    customFieldGroupService.deleteFieldFromGroup(id);
  }

  @PutMapping(value = "/saveReadOnlyAndWhiteList", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateFieldInGroup(@RequestParam(required = false) Boolean savePositions,
                                 @RequestBody CustomField customField) {
    customFieldGroupService.saveReadOnlyAndWhiteList(customField, savePositions);
  }

  // to update a list of them - (currently used when updating field order):
  @PutMapping(value = "/updateFieldsInGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateFieldsInGroup(@RequestBody List<CustomField> customFields) {
    customFieldGroupService.updateFieldsInGroup(customFields);
  }

  @GetMapping(value = "/getCustomFieldGroupsByObjectTypeId", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId (@RequestParam Long companyObjectTypeId) {
    return customFieldGroupService.getCustomFieldGroupsByObjectTypeId(companyObjectTypeId);
  }

  @GetMapping(value = "/getCustomFieldsInGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getCustomFieldsInGroup (@RequestParam Long groupId) {
    return customFieldGroupService.getCustomFieldsInGroup(groupId);
  }

  @GetMapping(value = "/getEventTypesAndFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleFieldType> getEventTypesAndFields () {
    return customFieldGroupService.getEventTypesAndFields();
  }

  @GetMapping(value = "/getAvailableCustomFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAvailableCustomFieldsInGroup (@RequestParam Long companyObjectTypeId,
                                                            @RequestParam Long groupId,
                                                            @RequestParam(required = false) Long processStepId) {
    return customFieldGroupService.getAvailableCustomFieldsInGroup(companyObjectTypeId, groupId, processStepId);
  }

  @PostMapping(value = "/addCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addCustomFieldGroup(customFieldGroup, customFieldGroup.getCompanyObjectTypeId());
  }

  @PostMapping(value = "/addProcessStepCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addProcessStepCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addProcessStepCustomFieldGroup(customFieldGroup);
  }

  @Data
  public static class DeleteWithRequirementParams {
    private Long customFieldGroupId, customFieldGroupAssignmentId;
  }

  @PutMapping(value = "/deleteWithRequirementChecks", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<FieldInUse> deleteWithRequirementChecks(@RequestBody DeleteWithRequirementParams params) {
    return customFieldGroupService.deleteWithRequirementChecks(params);
  }

  // to update just one:
  @PutMapping(value = "/updateCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup updateCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.updateCustomFieldGroup(customFieldGroup);
  }

  // to update a list of them:
  @PutMapping(value = "/updateCustomFieldGroups", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateCustomFieldGroups(@RequestBody List<CustomFieldGroup> customFieldGroups) {
    customFieldGroupService.updateCustomFieldGroups(customFieldGroups);
  }

  @GetMapping(value = "/getContactInsertFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getContactInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(ObjectType.CONTACT.id);
  }

  @GetMapping(value = "/getUserInsertFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getUserInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(ObjectType.USER.id);
  }

  @GetMapping(value = "/getOrgInsertFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getOrgInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(ObjectType.ORGANIZATION.id);
  }

  @PutMapping(value = "/updateFieldShowOnInsert", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateFieldShowOnInsert(@RequestBody CustomFieldObjectType objectType) {
    customFieldGroupService.updateFieldShowOnInsert(objectType);
  }
}
