package com.albatross.api.v1.flow.controllers;

import java.util.List;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.ObjectType;
import com.albatross.api.v1.flow.services.CustomFieldService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

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
  public List<CustomField> getAllCustomFields() {
    return customFieldService.getAllCustomFields();
  }

  @RequestMapping(value = "/getCustomFieldObjectTypes", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectType> getCustomFieldObjectTypes() {
    return customFieldService.getObjectTypes();
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomField saveField(@RequestBody CustomField customField) {
    // add the field and list of values
    CustomField field = customFieldService.saveField(customField);
    return field;
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteField(@PathVariable Long id) {
    customFieldService.deleteField(id);
  }

  @RequestMapping(value = "/getByParentProcessStep/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getByParentProcessStep(@PathVariable Long id) {
    return customFieldService.getByParentProcessStep(id);
  }
}
