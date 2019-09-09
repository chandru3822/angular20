package com.albatross.api.v1.flow.controllers;


import java.util.List;

import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.services.CustomFieldValueService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/{companyId}/customFieldValues")
public class CustomFieldValueController {

  private final CustomFieldValueService customFieldValueService;

  @GetMapping(value = "/customer", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomFieldValues(@PathVariable Long companyId,
                                                         @RequestParam Long primaryId) {
    return customFieldValueService.getCustomerCustomValues(companyId, primaryId);
  }

  @GetMapping(value = "/project/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CustomFieldGroup>> getFieldsByProjectId(@PathVariable Long companyId, @PathVariable Long projectId) {
    return new ResponseEntity<>(customFieldValueService.getProjectCustomValues(companyId, projectId), HttpStatus.OK);
  }
}
