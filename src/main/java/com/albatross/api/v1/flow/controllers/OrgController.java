package com.albatross.api.v1.flow.controllers;

import java.util.List;

import com.albatross.api.v1.flow.model.Org;
import com.albatross.api.v1.flow.services.OrgService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/org")
public class OrgController {

  @Autowired
  private OrgService orgService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> getOrgsForCompany() {
    return orgService.getOrgsForCompany();
  }

  @RequestMapping(value = "/owning", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> getOwningOrgsForCompany() {
    return orgService.getOwningOrgsForCompany();
  }

}
