package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.CompanyDefaultField;
import com.albatross.api.v1.flow.services.DefaultFieldService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/defaultField")
public class DefaultFieldController {

  private final DefaultFieldService defaultFieldService;

  // gets for all types
  @GetMapping(value = "/userProfile", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyDefaultField> getUserProfileDefaultFields() {
    return defaultFieldService.getCompanyDefaultFieldsByObjectType(ObjectType.USER.id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveCompanyDefaultField(@RequestBody CompanyDefaultField field) {
    defaultFieldService.saveCompanyDefaultField(field);
  }

}
