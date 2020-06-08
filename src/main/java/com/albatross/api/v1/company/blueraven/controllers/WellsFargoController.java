package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.WellsFargoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/api/v1/wellsfargo")
public class WellsFargoController {

  @Autowired
  private WellsFargoService wellsFargoService;

  @RequestMapping(value="/", method= RequestMethod.GET, produces= MediaType.TEXT_PLAIN_VALUE)
  public String renderFile() throws Exception {
    return wellsFargoService.renderFile();
  }
}
