package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldObjectType;
import com.albatross.api.v1.flow.services.CustomFieldService;
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
@RequestMapping(value = "/api/v1/flow/customField")
public class CustomFieldController {

  @Autowired
  private CustomFieldService customFieldService;

  @RequestMapping(value = "/getAll", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAllCustomFields(@RequestParam Long companyId) {
    return customFieldService.getAllCustomFields(companyId);
  }

  @RequestMapping(value = "/getCustomFieldObjectTypes", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldObjectType> getCustomFieldObjectTypes(@RequestParam Long companyId) {
    return customFieldService.getCustomFieldObjectTypes(companyId);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomField saveField(@RequestBody CustomField customField) {
    return customFieldService.saveField(customField);
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteField(@PathVariable("id") Long fieldId) {
    customFieldService.deleteField(fieldId);
  }
}
