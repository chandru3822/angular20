package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.flow.model.CustomField;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/customField/values")
public class BlueravenCustomFieldValueController {

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getCustomFields() {
    return null;
  }
}
