package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFiledFilterCriteria;
import com.albatross.api.v1.flow.services.CustomFieldService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/flow/customField", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class CustomFieldController {

  private final CustomFieldService customFieldService;

  @GetMapping(value = "/getAll")
  public List<CustomField> getAllCustomFields(CustomFiledFilterCriteria criteria) {
    return customFieldService.getAllCustomFields(criteria);
  }

  @GetMapping(value = "/{id}")
  public CustomField getOneCustomField(@PathVariable Long id) {
    return customFieldService.findCustomFieldById(id);
  }

  @PostMapping(value = "")
  public CustomField saveField(@RequestBody CustomField customField) throws SQLException {
    // add the field and list of values
    return customFieldService.saveField(customField);
  }

  @PutMapping(value = "/delete/{id}")
  public List<CustomField> deleteField(@PathVariable Long id) {
    // can't make this a delete request as we have to check for list of fields in use and return
    // those
    return customFieldService.deleteField(id);
  }

  @GetMapping(value="/getUses/{id}")
  public List<CustomField> getUses(@PathVariable Long id) {
      return customFieldService.getGroupsUsingField(id);
  }

  @GetMapping(value = "/getByProcessStepEvent/{id}")
  public List<CustomField> getByProcessStepEvent(@PathVariable Long id) {
    return customFieldService.getByProcessStepEvent(id);
  }

  @GetMapping(value = "/getByEvent/{id}")
  public List<CustomField> getByEvent(@PathVariable Long id) {
    return customFieldService.getByEvent(id);
  }

  @GetMapping(value = "/getByParentProcessStep/{id}")
  public List<CustomField> getByParentProcessStep(@PathVariable Long id,
                                                  @RequestParam(required = false) Boolean excludedUnhandledDataTypes) {
    return customFieldService.getByParentProcessStep(id, excludedUnhandledDataTypes);
  }

  @GetMapping(value = "/getByParentType/{id}")
  public List<CustomField> getByParentType(@PathVariable Long id,
                                           @RequestParam(required = false) Boolean excludedUnhandledDataTypes) {
    return customFieldService.getByParentType(id, excludedUnhandledDataTypes);
  }
}
