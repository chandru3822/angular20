package com.albatross.api.v1.company.blueraven.controllers.featDB.incentive;

import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.company.blueraven.services.featDB.IncentiveService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PostAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/featDb/incentive")
public class IncentiveController {

  private final IncentiveService incentiveService;

  @GetMapping(value = "/list/all")
  public List<Incentive> getAllIncentive() {
    return incentiveService.getAllIncentives();
  }

  @PostAuthorize("returnObject.get().getArchived() == true && hasFeatureAccessLevel('INCENTIVE_ADMIN') || returnObject.get().getArchived() == false")
  @GetMapping(value = "/{id}")
  public Optional<IncentiveDetail> getIncentiveById(@PathVariable Long id) {
    return incentiveService.getIncentiveById(id);
  }

  @GetMapping(value = "/list/type")
  public List<IncentiveType> getAllType() {
    return incentiveService.getAllTypes();
  }
  @GetMapping(value = "/list/status")
  public List<IncentiveStatus> getAllStatus() {
    return incentiveService.getAllStatuses();
  }

  @PostMapping(value = "")
  public Optional<IncentiveDetail> createIncentive(@RequestBody Incentive incentive) {
    return incentiveService.updateIncentive(incentive);
  }

  @PutMapping(value = "/simpleUpdate")
  public Optional<IncentiveDetail> simpleUpdate(@RequestBody Incentive incentive) {
    return incentiveService.simpleUpdate(incentive);
  }

  @PutMapping(value = "")
  public Optional<IncentiveDetail> editIncentive(@RequestBody Incentive incentive) {
    return incentiveService.updateIncentive(incentive);
  }

  @DeleteMapping(value="/{id}/archive")
  public void deleteIncentive(@PathVariable Long id) {
      incentiveService.deleteIncentive(id);
  }

  @PostMapping(value = "/{id}/restore")
  public Optional<IncentiveDetail> restoreAhj(@PathVariable Long id) {
    return incentiveService.restoreIncentive(id);
  }
  // CONTACTS
  @PostMapping(value = "/{incentiveId}/contacts")
  public Optional<FeatDbContact> addIncentiveContact(@PathVariable Long incentiveId,
                                                   @RequestBody FeatDbContact utilityContact) {
    return incentiveService.saveIncentiveContact(incentiveId, null, utilityContact);
  }

  @PutMapping(value = "/{incentiveId}/contacts/{contactId}")
  public Optional<FeatDbContact> updateIncentiveContact(@PathVariable Long incentiveId,
                                                      @PathVariable Long contactId,
                                                      @RequestBody FeatDbContact utilityContact) {
    return incentiveService.saveIncentiveContact(incentiveId, contactId, utilityContact);
  }

  @PutMapping(value = "/contacts/{contactId}/archive")
  public void deleteIncentiveContact(@PathVariable Long contactId) {
    incentiveService.deleteIncentiveContact(contactId);
  }

  // LINKS
  @PostMapping(value = "/{incentiveId}/links")
  public Optional<FeatDbLink> addIncentiveLink(@PathVariable Long incentiveId,
                                             @RequestBody FeatDbLink link) {
    return incentiveService.saveIncentiveLink(incentiveId, null, link);
  }

  @PutMapping(value = "/{incentiveId}/links/{linkId}")
  public Optional<FeatDbLink> updateIncentiveLink(@PathVariable Long incentiveId,
                                                @PathVariable Long linkId,
                                                @RequestBody FeatDbLink link) {
    return incentiveService.saveIncentiveLink(incentiveId, linkId, link);
  }

  @PutMapping(value = "/links/{linkId}/archive")
  public void deleteIncentiveLink(@PathVariable Long linkId) {
    incentiveService.deleteIncentiveLink(linkId);
  }

  @GetMapping(value="/{incentiveId}/getIncentiveHistory")
  public List<DatabaseHistory> getAhjDesignHistory(@PathVariable Long incentiveId) {
    return incentiveService.getIncentiveHistory(incentiveId);
  }
}
