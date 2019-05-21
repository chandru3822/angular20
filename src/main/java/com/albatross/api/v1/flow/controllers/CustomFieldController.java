package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.services.CustomFieldService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@RestController
@RequestMapping(value = "/api/v1/flow/customField")
public class CustomFieldController {

  @Autowired
  private CustomFieldService customFieldService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public String getAllCustomFields() {
    return customFieldService.testing();
  }
}
