package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.org.OrgFilter;
import com.albatross.api.v1.flow.services.OrgService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
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
  public List<Org> getSchedulingOrgs(@RequestParam(required = false) Long stateId,
                                     @RequestParam Boolean isSchedulingTool) {
    return orgService.getSchedulingOrgs(stateId, isSchedulingTool);
  }

  @GetMapping(value = "/{id}/users", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getUsersInOrg(@PathVariable Long id) {
    return orgService.getUsersInOrg(id);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Org getOrg(@PathVariable Long id) {
    return orgService.getOrg(id);
  }

  @GetMapping(value = "/getOrgsByType/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> getOrgsByType(@PathVariable Long typeId) {
    return orgService.getOrgsByType(typeId);
  }

  @GetMapping(value = "/exportOrgs", produces = "text/csv")
  public ResponseEntity exportOrgs(@RequestParam String query) {
    return orgService.exportOrgs(query);
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

  @GetMapping(value = "/user/{userId}/calendars", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> getOrgCalendarsForUser(@PathVariable Long userId) {
    return orgService.getOrgCalendarsForUser(userId);
  }

  @PostMapping(value = "/user/calendar", produces = MediaType.APPLICATION_JSON_VALUE)
  public UserOrgAccess saveOrgCalendarToUser(@RequestBody UserOrgAccess userOrgAccess) {
    return orgService.saveOrgCalendarToUser(userOrgAccess);
  }

  @DeleteMapping(value = "/user/calendar/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteOrgCalendarFromUser(@PathVariable Long id) {
    orgService.deleteOrgCalendarFromUser(id);
  }

  @GetMapping(value = "/{orgId}/attachments", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Attachment>> getOrgAttachments(@PathVariable Long orgId,
                                                             @PathVariable(required = false) Boolean isMobile) {
    return new ResponseEntity<>(orgService.getOrgAttachments(orgId, isMobile), HttpStatus.OK);
  }

  @PostMapping(value = "/{orgId}/linkAttachment/{attachmentId}")
  public void linkAttachment(@PathVariable Long orgId,
                             @PathVariable Long attachmentId) {
    orgService.linkAttachment(orgId, attachmentId);
  }

  @PostMapping(value = "/{orgId}/attachment", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Attachment> uploadOrgAttachment(@PathVariable Long orgId,
                                                         @RequestParam Long attachmentTypeId,
                                                         @RequestParam("file") MultipartFile file) throws IOException {
    return new ResponseEntity<>(orgService.addAttachment(file, orgId, attachmentTypeId), HttpStatus.OK);
  }

}
