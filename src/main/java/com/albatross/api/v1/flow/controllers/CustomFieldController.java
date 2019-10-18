package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.CompanyObjectType;
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

  @GetMapping(value = "/getAll", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAllCustomFields() {
    return customFieldService.getAllCustomFields();
  }

  @GetMapping(value = "/getCustomFieldObjectTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyObjectType> getCustomFieldObjectTypes() {
    return customFieldService.getCompanyObjectTypes();
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public CustomField saveField(@RequestBody CustomField customField) {
    // add the field and list of values
    CustomField field = customFieldService.saveField(customField);
    return field;
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteField(@PathVariable Long id) {
    customFieldService.deleteField(id);
  }

  @GetMapping(value = "/getByParentProcessStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getByParentProcessStep(@PathVariable Long id) {
    return customFieldService.getByParentProcessStep(id);
  }

  @GetMapping(value = "/getByParentType/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getByParentType(@PathVariable Long id) {
    return customFieldService.getByParentType(id);
  }

  @GetMapping(value = "/listOfValuesByOption/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ListOfValue> getListOfValuesByOptionId(@PathVariable Long id) {
    //the id used here is the id of one of the available options, need to work up and get the full list from that item
    return customFieldService.getListOfValuesByOptionId(id);
  }
}
