package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CustomField;
import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldGroupService;
import io.swagger.v3.oas.annotations.Hidden;
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
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/customFieldGroup")
public class BlueravenCustomFieldGroupController {

  @Autowired
  private BlueravenCustomFieldGroupService customFieldGroupService;

  @GetMapping(value = "/getCustomFieldGroupAssignmentsByObjectType", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomFieldGroupAssignmentsByObjectTypeId (@RequestParam Long sourceId,
                                                                              @RequestParam Long objectTypeId) {
    return customFieldGroupService.getCustomFieldGroupAssignmentsByObjectTypeId(sourceId, objectTypeId);
  }

  @GetMapping(value = "/getCustomFieldGroupsByObjectTypeId", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId (@RequestParam Long companyObjectTypeId) {
    return customFieldGroupService.getCustomFieldGroupsByObjectTypeId(companyObjectTypeId);
  }

  @PostMapping(value = "/addCustomFieldGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addCustomFieldGroup(customFieldGroup, customFieldGroup.getObjectTypeId());
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

  //delete a group
  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCfg(@PathVariable Long id) {
    customFieldGroupService.deleteFieldGroup(id);
  }

  //delete a field assignment in a group
  @DeleteMapping(value = "/assignment/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCfga(@PathVariable Long id) {
    customFieldGroupService.deleteFieldFromGroup(id);
  }

  @GetMapping(value = "/getAvailableCustomFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAvailableCustomFieldsInGroup (@RequestParam Long objectTypeId,
                                                            @RequestParam Long groupId) {
    return customFieldGroupService.getAvailableCustomFieldsInGroup(objectTypeId, groupId);
  }

  @PostMapping(value = "/addFieldToGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomField addFieldToGroup (@RequestBody CustomField customField) {
    return customFieldGroupService.addFieldToGroup(customField);
  }

  // to update a list of them - (currently used when updating field order):
  @PutMapping(value = "/updateFieldsInGroup", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateFieldsInGroup(@RequestBody List<CustomField> customFields) {
    customFieldGroupService.updateFieldsInGroup(customFields);
  }

  @PutMapping(value = "/saveUseParentData", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveUseParentData(@RequestBody CustomField customField) {
    customFieldGroupService.saveUseParentData(customField);
  }

}
