package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserOrgAccess;
import com.albatross.api.v1.flow.model.UserSearch;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.org.OrgFilter;
import com.albatross.api.v1.flow.services.OrgService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
@RequestMapping(value = "/api/v1/flow/org", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class OrgController {

  private final OrgService orgService;

  @GetMapping(value = "")
  public List<Org> getOrgsForCompany() {
    return orgService.getOrgsForCompany();
  }

  @GetMapping(value = "/getSchedulingOrgs")
  public List<Org> getSchedulingOrgs(@RequestParam(required = false) Long stateId,
                                     @RequestParam Boolean isSchedulingTool) {
    return orgService.getSchedulingOrgs(stateId, isSchedulingTool);
  }

  @GetMapping(value = "/{id}/users")
  public List<User> getUsersInOrg(@PathVariable Long id) {
    return orgService.getUsersInOrg(id);
  }

  @GetMapping(value = "/{id}")
  public Org getOrg(@PathVariable Long id) {
    return orgService.getOrg(id);
  }

  @GetMapping(value = "/getOrgsByType/{typeId}")
  public List<Org> getOrgsByType(@PathVariable Long typeId) {
    return orgService.getOrgsByType(typeId);
  }

  @GetMapping(value = "/exportOrgs", produces = "text/csv")
  public ResponseEntity exportOrgs(@RequestParam String query) {
    return orgService.exportOrgs(query);
  }

  @PutMapping(value = "")
  public Org saveOrg(@RequestBody Org org) {
    return orgService.saveOrg(org);
  }

  @GetMapping(value = "/filters")
  public List<OrgFilter> getOrgFiltersForCompany() {
    return orgService.getOrgFiltersForCompany();
  }

  @PutMapping(value = "/filters")
  public OrgFilter saveOrgFilter(@RequestBody OrgFilter filter) {
    return orgService.saveOrgFilter(filter);
  }

  @DeleteMapping(value = "/filters/{id}")
  public void deleteOrgFilter(@PathVariable Long id) {
    orgService.deleteOrgFilter(id);
  }

  @PostMapping(value = "/orgHierarchyFilter")
  public List<OrgFilter> getHierarchyFilteredOrgsForCompany(@RequestBody UserSearch search) {
    return orgService.getHierarchyFilteredOrgsForCompany(search.getOrgs());
  }

  @GetMapping(value = "/user/{userId}/calendars")
  public List<Org> getOrgCalendarsForUser(@PathVariable Long userId) {
    return orgService.getOrgCalendarsForUser(userId);
  }

  @PostMapping(value = "/user/calendar")
  public UserOrgAccess saveOrgCalendarToUser(@RequestBody UserOrgAccess userOrgAccess) {
    return orgService.saveOrgCalendarToUser(userOrgAccess);
  }

  @DeleteMapping(value = "/user/calendar/{id}")
  public void deleteOrgCalendarFromUser(@PathVariable Long id) {
    orgService.deleteOrgCalendarFromUser(id);
  }

  @GetMapping(value = "/{orgId}/attachments")
  public ResponseEntity<List<Attachment>> getOrgAttachments(@PathVariable Long orgId,
                                                            @RequestParam(required = false) Boolean isMobile,
                                                            @RequestParam(required = false) Boolean linked) {
    return new ResponseEntity<>(orgService.getOrgAttachments(orgId, isMobile, linked), HttpStatus.OK);
  }

  @PostMapping(value = "/{orgId}/linkAttachment/{attachmentId}")
  public void linkAttachment(@PathVariable Long orgId,
                             @PathVariable Long attachmentId,
                             @RequestParam Boolean doLink) {
    orgService.linkAttachment(orgId, attachmentId, doLink);
  }

  @PostMapping(value = "/{orgId}/attachment")
  public ResponseEntity<Attachment> uploadOrgAttachment(@PathVariable Long orgId,
                                                        @RequestParam Long attachmentTypeId,
                                                        @RequestParam String displayName,
                                                        @RequestParam("file") MultipartFile file) throws IOException {
    return new ResponseEntity<>(orgService.addAttachment(file, orgId, attachmentTypeId, displayName), HttpStatus.OK);
  }

}
