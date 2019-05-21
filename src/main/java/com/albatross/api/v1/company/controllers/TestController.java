package com.albatross.api.v1.company.controllers;

import com.albatross.api.v1.company.services.TestService;
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
@RequestMapping(value = "/api/v1/company/test")
public class TestController {

  @Autowired
  private TestService testService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public String getAllSalesAreas() {
    return testService.testing();
  }
}
