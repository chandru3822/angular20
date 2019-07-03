package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.ObjectType;
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
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/customField")
public class CustomFieldController {

  @Autowired
  private CustomFieldService customFieldService;

  @RequestMapping(value = "/getAll", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAllCustomFields(@PathVariable Long companyId) {
    return customFieldService.getAllCustomFields(companyId);
  }

  @RequestMapping(value = "/getCustomFieldObjectTypes", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectType> getCustomFieldObjectTypes(@PathVariable Long companyId) {
    return customFieldService.getObjectTypes(companyId);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomField saveField(@RequestBody CustomField customField) {
    // add the field and list of values
    CustomField field = customFieldService.saveField(customField);
    return field;
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteField(@PathVariable Long id) {
    customFieldService.deleteField(id);
  }
}
