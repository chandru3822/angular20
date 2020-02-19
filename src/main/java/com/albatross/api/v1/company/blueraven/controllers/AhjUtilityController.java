package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.company.blueraven.services.AhjUtilityService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/ahjUtility")
public class AhjUtilityController {
    @Autowired
    private AhjUtilityService ahjUtilityService;

    @GetMapping(value = "/list/all")
    public List<AhjUtility> getAllAhjUtilities() {
        return ahjUtilityService.getAllAhjUtilities();
    }

    @GetMapping(value = "/{id}")
    public Optional<AhjUtilityDetail> getUtilityById(@PathVariable Long id) {
        return ahjUtilityService.getUtilityById(id);
    }

    @PostMapping(value = "")
    public Optional<AhjUtilityDetail> createUtility(@RequestBody AhjUtility utility) {
        return ahjUtilityService.updateUtility(utility);
    }

    @PutMapping(value = "/simpleUpdate")
    public Optional<AhjUtilityDetail> simpleUpdate(@RequestBody AhjUtility utility) {
        return ahjUtilityService.simpleUpdate(utility);
    }

    @PutMapping(value = "")
    public Optional<AhjUtilityDetail> editUtility(@RequestBody AhjUtility utility) {
        return ahjUtilityService.updateUtility(utility);
    }

    // CONTACTS
    @PostMapping(value = "/{utilityId}/contacts")
    public Optional<AhjContact> addUtilityContact(@PathVariable Long utilityId,
                                                  @RequestBody AhjContact utilityContact) {
        return ahjUtilityService.saveUtilityContact(utilityId, null, utilityContact);
    }

    @PutMapping(value = "/{utilityId}/contacts/{contactId}")
    public Optional<AhjContact> updateUtilityContact(@PathVariable Long utilityId,
                                                     @PathVariable Long contactId,
                                                     @RequestBody AhjContact utilityContact) {
        return ahjUtilityService.saveUtilityContact(utilityId, contactId, utilityContact);
    }

    @PutMapping(value = "/contacts/{contactId}/archive")
    public void deleteUtilityContact(@PathVariable Long contactId) {
        ahjUtilityService.deleteUtilityContact(contactId);
    }

    // CHECKLISTS
    @PostMapping(value = "/{utilityId}/checklist")
    public Optional<AhjChecklistItem> addUtilityChecklistItem(@PathVariable Long utilityId,
                                                              @RequestBody AhjChecklistItem item) {
        return ahjUtilityService.saveChecklistItem(utilityId, null, item);
    }

    @PutMapping(value = "/{utilityId}/checklist/{checklistId}")
    public Optional<AhjChecklistItem> updateUtilityChecklistItem(@PathVariable Long utilityId,
                                                                 @PathVariable Long checklistId,
                                                                 @RequestBody AhjChecklistItem item) {
        return ahjUtilityService.saveChecklistItem(utilityId, checklistId, item);
    }

    @PutMapping(value = "/checklist/{itemId}/archive")
    public void deleteUtilityChecklistItem(@PathVariable Long itemId) {
        ahjUtilityService.deleteChecklistItem(itemId);
    }

    // LINKS
    @PostMapping(value = "/{utilityId}/links")
    public Optional<AhjLink> addUtilityLink(@PathVariable Long utilityId,
                                            @RequestBody AhjLink link) {
        return ahjUtilityService.saveUtilityLink(utilityId, null, link);
    }

    @PutMapping(value = "/{utilityId}/links/{linkId}")
    public Optional<AhjLink> updateUtilityLink(@PathVariable Long utilityId,
                                               @PathVariable Long linkId,
                                               @RequestBody AhjLink link) {
        return ahjUtilityService.saveUtilityLink(utilityId, linkId, link);
    }

    @PutMapping(value = "/links/{linkId}/archive")
    public void deleteUtilityLink(@PathVariable Long linkId) {
        ahjUtilityService.deleteUtilityLink(linkId);
    }
}
