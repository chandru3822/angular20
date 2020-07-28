package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyObjectType;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.services.CustomFieldService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
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
  public CustomField saveField(@RequestBody CustomField customField) throws SQLException {
    // add the field and list of values
    CustomField field = customFieldService.saveField(customField);
    return field;
  }

  @PutMapping(value = "/delete/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> deleteField(@PathVariable Long id) {
    //can't make this a delete request as we have to check for list of fields in use and return those
    return customFieldService.deleteField(id);
  }

  @GetMapping(value = "/getByParentProcessStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getByParentProcessStep(@PathVariable Long id) {
    return customFieldService.getByParentProcessStep(id);
  }

  @GetMapping(value = "/getByParentType/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getByParentType(@PathVariable Long id) {
    return customFieldService.getByParentType(id);
  }

}
