package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.WhiteListType;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.FieldInUse;
import com.albatross.api.v1.flow.model.ScheduleFieldType;
import com.albatross.api.v1.flow.services.CustomFieldGroupService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/customFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class CustomFieldGroupController {

  private final CustomFieldGroupService customFieldGroupService;

  @PostMapping(value = "/addFieldToGroup")
  public CustomField addFieldToGroup (@RequestBody CustomField customField) {
    return customFieldGroupService.addFieldToGroup(customField);
  }

  @PostMapping(value = "/moveFieldToOtherGroup/{id}")
  public CustomField moveFieldToOtherGroup (@PathVariable Long id,
                                            @RequestBody CustomField customField) {
    return customFieldGroupService.moveFieldToOtherGroup(customField, id);
  }


  @DeleteMapping(value = "/deleteFieldFromGroup/{id}")
  public void deleteFieldInGroup(@PathVariable Long id) {
    customFieldGroupService.deleteFieldFromGroup(id);
  }

  @PutMapping(value = "/saveUseParentData")
  public void saveUseParentData(@RequestBody CustomField customField) {
    customFieldGroupService.saveUseParentData(customField);
  }

  @PutMapping(value = "/saveReadOnlyAndWhiteList")
  public void saveReadOnlyAndWhiteList(@RequestParam(required = false) Boolean savePositions,
                                       @RequestBody CustomField customField) {
    customFieldGroupService.saveCfgaAndWhiteList(customField, true, savePositions, WhiteListType.CFGA_READ_ONLY.id);
  }

  @PutMapping(value = "/saveDetailView/{cfgaId}")
  public void saveDetailView(@PathVariable Long cfgaId,
                             @RequestParam Boolean detailView) {
    customFieldGroupService.saveDetailView(cfgaId, detailView);
  }

  @PutMapping(value = "/saveHiddenAndWhiteList")
  public void saveHiddenAndWhiteList(@RequestParam(required = false) Boolean savePositions,
                                     @RequestBody CustomField customField) {
    customFieldGroupService.saveCfgaAndWhiteList(customField, false, savePositions, WhiteListType.CFGA_HIDDEN.id);
  }

  // to update a list of them - (currently used when updating field order):
  @PutMapping(value = "/updateFieldsInGroup")
  public void updateFieldsInGroup(@RequestBody List<CustomField> customFields) {
    customFieldGroupService.updateFieldsInGroup(customFields);
  }

  @GetMapping(value = "/getCustomFieldGroupsByObjectTypeId")
  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId (@RequestParam Long companyObjectTypeId) {
    return customFieldGroupService.getCustomFieldGroupsByObjectTypeId(companyObjectTypeId);
  }

  @GetMapping(value = "/getCustomFieldsInGroup")
  public List<CustomField> getCustomFieldsInGroup (@RequestParam Long groupId) {
    return customFieldGroupService.getCustomFieldsInGroup(groupId);
  }

  @GetMapping(value = "/getNonEventCustomFieldGroupsByProcessStep/{id}")
  public List<CustomFieldGroup> getNonEventCustomFieldGroupsByProcessStep (@PathVariable Long id) {
    return customFieldGroupService.getNonEventCustomFieldGroupsByProcessStep(id);
  }

  @GetMapping(value = "/getEventTypesAndFields/{flowTypeId}")
  public List<ScheduleFieldType> getEventTypesAndFields (@PathVariable Long flowTypeId) {
    return customFieldGroupService.getEventTypesAndFields(flowTypeId);
  }

  @GetMapping(value = "/getAvailableCustomFields")
  public List<CustomField> getAvailableCustomFieldsInGroup (@RequestParam Long companyObjectTypeId,
                                                            @RequestParam Long groupId,
                                                            @RequestParam(required = false) Long processStepId,
                                                            @RequestParam(required = false) Long eventId) {
    return customFieldGroupService.getAvailableCustomFieldsInGroup(companyObjectTypeId, groupId, processStepId, eventId);
  }

  @PostMapping(value = "/addCustomFieldGroup")
  public CustomFieldGroup addCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addCustomFieldGroup(customFieldGroup, customFieldGroup.getCompanyObjectTypeId());
  }

  @PostMapping(value = "/addProcessStepCustomFieldGroup")
  public CustomFieldGroup addProcessStepCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addProcessStepCustomFieldGroup(customFieldGroup);
  }

  @PostMapping(value = "/addEventCustomFieldGroup")
  public CustomFieldGroup addEventCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addEventCustomFieldGroup(customFieldGroup);
  }

  @PutMapping(value = "/deleteWithRequirementChecks")
  public List<FieldInUse> deleteWithRequirementChecks(@RequestBody DeleteWithRequirementParams params) {
    return customFieldGroupService.deleteWithRequirementChecks(params);
  }

  // to update just one:
  @PutMapping(value = "/updateCustomFieldGroup")
  public CustomFieldGroup updateCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.updateCustomFieldGroup(customFieldGroup);
  }

  // to update a list of them:
  @PutMapping(value = "/updateCustomFieldGroups")
  public void updateCustomFieldGroups(@RequestBody List<CustomFieldGroup> customFieldGroups) {
    customFieldGroupService.updateCustomFieldGroups(customFieldGroups);
  }

  @GetMapping(value = "/getContactInsertFields")
  public List<CustomFieldGroup> getContactInsertFields (@RequestParam(required = false) Long companyId) {
    return customFieldGroupService.getInsertFieldsByType(companyId, ObjectType.CONTACT.id);
  }

  @GetMapping(value = "/getUserInsertFields")
  public List<CustomFieldGroup> getUserInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(null, ObjectType.USER.id);
  }

  @GetMapping(value = "/getOrgInsertFields")
  public List<CustomFieldGroup> getOrgInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(null, ObjectType.ORGANIZATION.id);
  }

  @PutMapping(value = "/updateFieldShowOrRequire")
  public void updateFieldShowOrRequire(@RequestBody CustomField customField) {
    customFieldGroupService.updateFieldShowOrRequire(customField);
  }

  @Data
  public static class DeleteWithRequirementParams {
    private Long customFieldGroupId, customFieldGroupAssignmentId;
  }
}
