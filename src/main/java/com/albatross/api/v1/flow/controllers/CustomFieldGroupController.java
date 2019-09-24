package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldObjectType;
import com.albatross.api.v1.flow.services.CustomFieldGroupService;
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

  @RequestMapping(value = "/addFieldToGroup", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomField addFieldToGroup (@RequestBody CustomField customField) {
    return customFieldGroupService.addFieldToGroup(customField);
  }

  @RequestMapping(value = "/deleteFieldFromGroup/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteFieldInGroup(@PathVariable Long id) {
    customFieldGroupService.deleteFieldFromGroup(id);
  }

  // to update just one:
  @RequestMapping(value = "/updateFieldInGroup", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateFieldInGroup(@RequestBody CustomField customField) {
    customFieldGroupService.updateFieldInGroup(customField);
  }

  // to update a list of them:
  @RequestMapping(value = "/updateFieldsInGroup", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateFieldsInGroup(@RequestBody List<CustomField> customFields) {
    customFieldGroupService.updateFieldsInGroup(customFields);
  }

  @RequestMapping(value = "/getCustomFieldGroupsByObjectTypeId", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomFieldGroupsByObjectTypeId (@RequestParam Long objectTypeId) {
    return customFieldGroupService.getCustomFieldGroupsByObjectTypeId(objectTypeId);
  }

  @RequestMapping(value = "/getCustomFieldsInGroup", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getCustomFieldsInGroup (@RequestParam Long groupId) {
    return customFieldGroupService.getCustomFieldsInGroup(groupId);
  }

  @RequestMapping(value = "/getAvailableCustomFields", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAvailableCustomFieldsInGroup (@RequestParam Long objectTypeId,
                                                            @RequestParam Long groupId,
                                                            @RequestParam(required = false) Long processStepId) {
    return customFieldGroupService.getAvailableCustomFieldsInGroup(objectTypeId, groupId, processStepId);
  }

  @RequestMapping(value = "/addCustomFieldGroup", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup addCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.addCustomFieldGroup(customFieldGroup);
  }


  @RequestMapping(value = "/deleteCustomFieldGroup/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCustomFieldGroup(@PathVariable Long id) {
    customFieldGroupService.deleteCustomFieldGroup(id);
  }

  // to update just one:
  @RequestMapping(value = "/updateCustomFieldGroup", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroup updateCustomFieldGroup(@RequestBody CustomFieldGroup customFieldGroup) {
    return customFieldGroupService.updateCustomFieldGroup(customFieldGroup);
  }

  // to update a list of them:
  @RequestMapping(value = "/updateCustomFieldGroups", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateCustomFieldGroups(@RequestBody List<CustomFieldGroup> customFieldGroups) {
    customFieldGroupService.updateCustomFieldGroups(customFieldGroups);
  }

  @RequestMapping(value = "/getCustomerInsertFields", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomerInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(ObjectType.CUSTOMER.id);
  }

  @RequestMapping(value = "/getUserInsertFields", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getUserInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(ObjectType.USER.id);
  }

  @RequestMapping(value = "/getOrgInsertFields", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getOrgInsertFields () {
    return customFieldGroupService.getInsertFieldsByType(ObjectType.ORGANIZATION.id);
  }

  @RequestMapping(value = "/updateFieldShowOnInsert", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateFieldShowOnInsert(@RequestBody CustomFieldObjectType objectType) {
    customFieldGroupService.updateFieldShowOnInsert(objectType);
  }
}
