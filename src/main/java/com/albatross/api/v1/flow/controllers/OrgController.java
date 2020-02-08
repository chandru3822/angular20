package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Org;
import com.albatross.api.v1.flow.model.OrgFilter;
import com.albatross.api.v1.flow.model.UserSearch;
import com.albatross.api.v1.flow.services.OrgService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> getOrgsForCompany() {
    return orgService.getOrgsForCompany();
  }

  @GetMapping(value = "/getSchedulingOrgs", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> getSchedulingOrgs(@RequestParam(required = false) Long stateId) {
    return orgService.getSchedulingOrgs(stateId);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Org getOrg(@PathVariable Long id) {
    return orgService.getOrg(id);
  }

  @GetMapping(value = "/getOrgsByType/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> getOrgsByType(@PathVariable Long typeId) {
    return orgService.getOrgsByType(typeId);
  }

  @GetMapping(value="/search", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Page<Org>> searchOrgs(@RequestParam String query, Pageable pageable) {
    return new ResponseEntity<>(orgService.searchOrgs(query, pageable), HttpStatus.OK);
  }

  @GetMapping(value = "/exportOrgs", produces = "text/csv")
  public ResponseEntity exportOrgs(@RequestParam String query) {
    return orgService.exportOrgs(query);
  }

  @GetMapping(value = "/owning", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> getOwningOrgsForCompany() {
    return orgService.getOwningOrgsForCompany();
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Org saveOrg(@RequestBody Org org) {
    return orgService.saveOrg(org);
  }

  @GetMapping(value = "/filters", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OrgFilter> getOrgFiltersForCompany() {
    return orgService.getOrgFiltersForCompany();
  }

  @PutMapping(value = "/filters", produces = MediaType.APPLICATION_JSON_VALUE)
  public OrgFilter saveOrgFilter(@RequestBody OrgFilter filter) {
    return orgService.saveOrgFilter(filter);
  }

  @DeleteMapping(value = "/filters/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteOrgFilter(@PathVariable Long id) {
    orgService.deleteOrgFilter(id);
  }

  @PostMapping(value = "/orgHierarchyFilter", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OrgFilter> getHierarchyFilteredOrgsForCompany(@RequestBody UserSearch search) {
    return orgService.getHierarchyFilteredOrgsForCompany(search.getOrgs());
  }

}
