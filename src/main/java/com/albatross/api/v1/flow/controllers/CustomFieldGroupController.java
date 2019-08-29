package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldGroupType;
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
  public void addFieldToGroup (@RequestBody CustomField customField) {
    customFieldGroupService.addFieldToGroup(customField);
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
  public List<CustomFieldGroupType> getCustomFieldGroupsByObjectTypeId (@RequestParam Long objectTypeId) {
    return customFieldGroupService.getCustomFieldGroupsByObjectTypeId(objectTypeId);
  }

  @RequestMapping(value = "/getCustomFieldsInGroup", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getCustomFieldsInGroup (@RequestParam Long groupTypeId) {
    return customFieldGroupService.getCustomFieldsInGroup(groupTypeId);
  }

  @RequestMapping(value = "/getAvailableCustomFieldsInGroup", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAvailableCustomFieldsInGroup (@RequestParam Long objectTypeId,
                                                            @RequestParam Long groupTypeId) {
    return customFieldGroupService.getAvailableCustomFieldsInGroup(objectTypeId, groupTypeId);
  }

  @RequestMapping(value = "/addCustomFieldGroupType", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroupType addCustomFieldGroupType(@RequestBody CustomFieldGroupType customFieldGroupType) {
    return customFieldGroupService.addCustomFieldGroupType(customFieldGroupType);
  }


  @RequestMapping(value = "/deleteCustomFieldGroupType/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCustomFieldGroupType(@PathVariable Long id) {
    customFieldGroupService.deleteCustomFieldGroupType(id);
  }

  // to update just one:
  @RequestMapping(value = "/updateCustomFieldGroupType", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomFieldGroupType updateCustomFieldGroupType(@RequestBody CustomFieldGroupType customFieldGroupType) {
    return customFieldGroupService.updateCustomFieldGroupType(customFieldGroupType);
  }

  // to update a list of them:
  @RequestMapping(value = "/updateCustomFieldGroupTypes", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateCustomFieldGroupTypes(@RequestBody List<CustomFieldGroupType> customFieldGroupTypes) {
    customFieldGroupService.updateCustomFieldGroupTypes(customFieldGroupTypes);
  }
}
