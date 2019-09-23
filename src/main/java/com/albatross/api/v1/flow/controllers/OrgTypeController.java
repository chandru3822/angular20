package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.OrgType;
import com.albatross.api.v1.flow.services.OrgTypeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/orgType")
public class OrgTypeController {

  @Autowired
  private OrgTypeService orgTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OrgType> getOrgTypesForCompany() {
    return orgTypeService.getOrgTypesForCompany();
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public OrgType saveOrgType(@RequestBody OrgType type) {
    return orgTypeService.saveOrgType(type);
  }

}
