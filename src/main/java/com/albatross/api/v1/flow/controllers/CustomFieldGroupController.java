package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.WhiteListType;
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

  @PutMapping(value = "/saveUseParentData", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveUseParentData(@RequestBody CustomField customField) {
    customFieldGroupService.saveUseParentData(customField);
  }

  @PutMapping(value = "/saveReadOnlyAndWhiteList", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveReadOnlyAndWhiteList(@RequestParam(required = false) Boolean savePositions,
                                       @RequestBody CustomField customField) {
    customFieldGroupService.saveCfgaAndWhiteList(customField, true, savePositions, WhiteListType.CFGA_READ_ONLY.id);
  }

  @PutMapping(value = "/saveDetailView/{cfgaId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveDetailView(@PathVariable Long cfgaId,
                             @RequestParam Boolean detailView) {
    customFieldGroupService.saveDetailView(cfgaId, detailView);
  }

  @PutMapping(value = "/saveHiddenAndWhiteList", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveHiddenAndWhiteList(@RequestParam(required = false) Boolean savePositions,
                                     @RequestBody CustomField customField) {
    customFieldGroupService.saveCfgaAndWhiteList(customField, false, savePositions, WhiteListType.CFGA_HIDDEN.id);
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

  @GetMapping(value = "/getNonEventCustomFieldGroupsByProcessStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getNonEventCustomFieldGroupsByProcessStep (@PathVariable Long id) {
    return customFieldGroupService.getNonEventCustomFieldGroupsByProcessStep(id);
  }

  @GetMapping(value = "/getEventTypesAndFields/{flowTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ScheduleFieldType> getEventTypesAndFields (@PathVariable Long flowTypeId) {
    return customFieldGroupService.getEventTypesAndFields(flowTypeId);
  }

  @GetMapping(value = "/getAvailableCustomFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAvailableCustomFieldsInGroup (@RequestParam Long companyObjectTypeId,
                                                            @RequestParam Long groupId,
                                                            @RequestParam(required = false) Long processStepId,
                                                            @RequestParam(required = false) Long eventId) {
    return customFieldGroupService.getAvailableCustomFieldsInGroup(companyObjectTypeId, groupId, processStepId, eventId);
  }

  @PostMapping(value = "/addCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addCustomFieldGroup(customFieldGroup, customFieldGroup.getCompanyObjectTypeId());
  }

  @PostMapping(value = "/addProcessStepCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addProcessStepCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addProcessStepCustomFieldGroup(customFieldGroup);
  }

  @PostMapping(value = "/addEventCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addEventCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addEventCustomFieldGroup(customFieldGroup);
  }

  @PostMapping(value = "/addAttachmentCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addAttachmentCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addAttachmentCustomFieldGroup(customFieldGroup);
  }

  @PostMapping(value = "/addProcessStepAttachmentCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addProcessStepAttachmentCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addProcessStepAttachmentCustomFieldGroup(customFieldGroup);
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
  public List<CustomFieldGroup> getContactInsertFields (@RequestParam(required = false) Long companyId) {
    return customFieldGroupService.getInsertFieldsByType(companyId, ObjectType.CONTACT.id);
  }

  @GetMapping(value = "/getUserInsertFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getUserInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(null, ObjectType.USER.id);
  }

  @GetMapping(value = "/getOrgInsertFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getOrgInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(null, ObjectType.ORGANIZATION.id);
  }

  @PutMapping(value = "/updateFieldShowOrRequire", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateFieldShowOrRequire(@RequestBody CustomField customField) {
    customFieldGroupService.updateFieldShowOrRequire(customField);
  }
}
