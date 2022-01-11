package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldService;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.ListOfValue;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.List;

@Slf4j
@Hidden
@RestController
@RequiredArgsConstructor
@RequestMapping(
    value = "/api/v1/company/blueraven/customField",
    produces = MediaType.APPLICATION_JSON_VALUE)
public class BlueravenCustomFieldController {

  private final BlueravenCustomFieldService customFieldService;

  @GetMapping(value = "/getAll")
  public List<CustomField> getAllCustomFields() {
    return customFieldService.getAllCustomFields();
  }

  @PostMapping(value = "")
  public CustomField saveField(@RequestBody CustomField customField) throws SQLException {
    // add the field and list of values
    CustomField field = customFieldService.saveField(customField);
    return field;
  }

  @GetMapping(value = "/{id}/values")
  public List<ListOfValue> getCustomFieldListOfValues(
      @PathVariable Long id, @RequestParam String query) {
    return customFieldService.getCustomFieldListOfValues(id, query);
  }

  @PutMapping(value = "/delete/{id}")
  public List<CustomField> deleteField(@PathVariable Long id) {
    // can't make this a delete request as we have to check for list of fields in use and return
    // those
    return customFieldService.deleteField(id);
  }

  @GetMapping(value = "/{objectCode}")
  public List<CustomField> findAllByObjectCode(@PathVariable String objectCode) {
    return customFieldService.findCustomFieldsByObjectCode(objectCode);
  }
}
