package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CustomField;
import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldGroupService;
import io.swagger.v3.oas.annotations.Hidden;
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
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/customFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class BlueravenCustomFieldGroupController {

  private final BlueravenCustomFieldGroupService customFieldGroupService;

  @GetMapping(value = "/getCustomFieldGroupAssignmentsByObjectType")
  public List<CustomFieldGroup> getCustomFieldGroupAssignmentsByObjectTypeId (@RequestParam Long sourceId,
                                                                              @RequestParam Long objectTypeId) {
    return customFieldGroupService.getCustomFieldGroupAssignmentsByObjectTypeId(sourceId, objectTypeId);
  }

  @GetMapping(value = "/getCustomFieldGroupsByObjectTypeId")
  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId (@RequestParam Long companyObjectTypeId) {
    return customFieldGroupService.getCustomFieldGroupsByObjectTypeId(companyObjectTypeId);
  }

  @PostMapping(value = "/addCustomFieldGroup")
  public CustomFieldGroup addCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addCustomFieldGroup(customFieldGroup, customFieldGroup.getObjectTypeId());
  }

  @PutMapping(value = "/moveGroupToColumn")
  public CustomFieldGroup moveCustomFieldGroupToColumn(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.moveCustomFieldGroupToColumn(customFieldGroup);
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

  //delete a group
  @DeleteMapping(value = "/{id}")
  public void deleteCfg(@PathVariable Long id) {
    customFieldGroupService.deleteFieldGroup(id);
  }

  //delete a field assignment in a group
  @DeleteMapping(value = "/assignment/{id}")
  public void deleteCfga(@PathVariable Long id) {
    customFieldGroupService.deleteFieldFromGroup(id);
  }

  @GetMapping(value = "/getAvailableCustomFields")
  public List<CustomField> getAvailableCustomFieldsInGroup (@RequestParam Long objectTypeId,
                                                            @RequestParam Long groupId) {
    return customFieldGroupService.getAvailableCustomFieldsInGroup(objectTypeId, groupId);
  }

  @PostMapping(value = "/addFieldToGroup")
  public CustomField addFieldToGroup (@RequestBody CustomField customField) {
    return customFieldGroupService.addFieldToGroup(customField);
  }

  // to update a list of them - (currently used when updating field order):
  @PutMapping(value = "/updateFieldsInGroup")
  public void updateFieldsInGroup(@RequestBody List<CustomField> customFields) {
    customFieldGroupService.updateFieldsInGroup(customFields);
  }

  @PutMapping(value = "/saveUseParentData")
  public void saveUseParentData(@RequestBody CustomField customField) {
    customFieldGroupService.saveUseParentData(customField);
  }

  @PutMapping(value = "/updateRequired")
  public void updateRequired(@RequestBody CustomField customField) {
    customFieldGroupService.updateRequired(customField);
  }

  @PutMapping(value = "/saveMinMax")
  public void saveMinMax(@RequestBody CustomField customField) {
    customFieldGroupService.saveMinMax(customField);
  }

  @PutMapping(value="/updateConditionalId")
  public void updateConditionalOnId(@RequestBody CustomField customField){
    customFieldGroupService.updateConditionalOnId(customField);
  }

  @PutMapping(value="/saveReadOnlyAndWhiteList")
  public void updateReadOnlyAndWhiteList(@RequestBody CustomField customField){
    customFieldGroupService.updateReadOnlyAndWhiteList(customField);
  }

  @PutMapping(value="/saveHiddenAndWhiteList")
  public void updateHiddenAndWhiteList(@RequestBody CustomField customField){
    customFieldGroupService.updateHiddenAndWhiteList(customField);
  }
}
