package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/customFieldValues")
public class CustomFieldValueController {

  private final CustomFieldValueService customFieldValueService;

  @GetMapping(value = "/customer", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomFieldValues(@RequestParam Long primaryId) {
    return customFieldValueService.getCustomerCustomValues(primaryId);
  }

  @GetMapping(value = "/org", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getOrgCustomValues(@RequestParam Long primaryId) {
    return customFieldValueService.getOrgCustomValues(primaryId);
  }

  @GetMapping(value = "/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getUserCustomValues(@RequestParam Long primaryId) {
    return customFieldValueService.getUserCustomValues(primaryId);
  }

  @GetMapping(value = "/project/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CustomFieldGroup>> getFieldsByProjectId(@PathVariable Long projectId) {
    return new ResponseEntity<>(customFieldValueService.getProjectCustomValues(projectId), HttpStatus.OK);
  }

  @GetMapping(value = "/project/{projectId}/processStep", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CustomFieldGroup>> getFieldsByProjectProcessStepId(@PathVariable Long projectId,
                                                                                @RequestParam Long projectProcessStepId) {
    return new ResponseEntity<>(customFieldValueService.getProjectProcessStepCustomValues(projectProcessStepId), HttpStatus.OK);
  }
}
