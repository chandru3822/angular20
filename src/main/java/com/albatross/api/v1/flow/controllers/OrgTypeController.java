package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.OrgLevel;
import com.albatross.api.v1.flow.model.OrgType;
import com.albatross.api.v1.flow.services.OrgTypeService;
import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OrgTypeController {

  private final OrgTypeService orgTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OrgType> getOrgTypesForCompany() {
    return orgTypeService.getOrgTypesForCompany();
  }

  @GetMapping(value = "/schedulable", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OrgType> getSchedulableOrgTypesForCompany() {
    return orgTypeService.getSchedulableOrgTypesForCompany();
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public OrgType saveOrgType(@RequestBody OrgType type) {
    return orgTypeService.saveOrgType(type);
  }

  @GetMapping(value = "/levels", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OrgLevel> getOrgLevels() {
    return orgTypeService.getOrgLevels();
  }

  @PutMapping(value = "/level", produces = MediaType.APPLICATION_JSON_VALUE)
  public OrgLevel saveOrgLevel(@RequestBody OrgLevel level) {
    return orgTypeService.saveOrgLevel(level);
  }

  @DeleteMapping(value = "/level/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteOrgLevel(@PathVariable Long id) {
    orgTypeService.deleteOrgLevel(id);
  }

}
