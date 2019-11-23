package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.enums.AhjType;
import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.company.blueraven.services.AhjPermitService;
import com.albatross.api.v1.company.blueraven.services.AhjService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-18.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/ahj/{ahjId}/permit")
public class AhjPermitController {
    @Autowired
    private AhjPermitService ahjPermitService;

    @Autowired
    private AhjService ahjService;

    @GetMapping(value = "")
    public Optional<AhjPermitDetail> getAhjPermitDetail(@PathVariable Long ahjId) {
        return ahjPermitService.getAhjPermitDetailByAhjId(ahjId);
    }

    @PostMapping(value = "")
    public Optional<AhjPermitDetail> createAhjPermit(@PathVariable Long ahjId,
                                                     @RequestBody AhjPermit permit) {
        return ahjPermitService.saveAhjPermit(ahjId, null, permit);
    }

    @PutMapping(value = "/{permitId}")
    public Optional<AhjPermitDetail> updateAhjPermit(@PathVariable Long ahjId,
                                                     @PathVariable Long permitId,
                                                     @RequestBody AhjPermit permit) {
        return ahjPermitService.saveAhjPermit(ahjId, permitId, permit);
    }

    // CHECKLISTS
    @PostMapping(value = "/{permitId}/checklist")
    public Optional<AhjChecklistItem> addPermitChecklistItem(@PathVariable Long ahjId,
                                                             @PathVariable Long permitId,
                                                             @RequestBody AhjChecklistItem item) {
        return ahjService.saveChecklistItem(ahjId, permitId, null, item, AhjType.PERMIT);
    }

    @PutMapping(value = "/{permitId}/checklist/{itemId}")
    public Optional<AhjChecklistItem> updatePermitChecklistItem(@PathVariable Long ahjId,
                                                                @PathVariable Long permitId,
                                                                @PathVariable Long itemId,
                                                                @RequestBody AhjChecklistItem item) {
        return ahjService.saveChecklistItem(ahjId, permitId, itemId, item, AhjType.PERMIT);
    }

    @DeleteMapping(value = "/{permitId}/checklist/{itemId}")
    public void deletePermitChecklistItem(@PathVariable Long ahjId,
                                          @PathVariable Long permitId,
                                          @PathVariable Long itemId) {
        ahjService.deleteChecklistItem(ahjId, permitId, itemId);
    }

    // CONTACTS
    @PostMapping(value = "/{permitId}/contacts")
    public Optional<AhjContact> addAhjContact(@PathVariable Long permitId,
                                              @RequestBody AhjContact ahjContact) {
        return ahjService.saveAhjContact(permitId, null, ahjContact, AhjType.PERMIT);
    }

    @PutMapping(value = "/{permitId}/contacts/{contactId}")
    public Optional<AhjContact> updateAhjContact(@PathVariable Long permitId,
                                                 @PathVariable Long contactId,
                                                 @RequestBody AhjContact ahjContact) {
        return ahjService.saveAhjContact(permitId, contactId, ahjContact, AhjType.PERMIT);
    }

    @DeleteMapping(value = "/{permitId}/contacts/{contactId}")
    public void removeAhjContact(@PathVariable Long permitId,
                                 @PathVariable Long contactId) {
        ahjService.deleteAhjContact(permitId, contactId);
    }

    // LINKS
    @PostMapping(value = "/{permitId}/links")
    public Optional<AhjLink> addPermitLink(@PathVariable Long ahjId,
                                           @PathVariable Long permitId,
                                           @RequestBody AhjLink link) {
        return ahjPermitService.savePermitLink(ahjId, permitId, null, link);
    }

    @PutMapping(value = "/{permitId}/links/{linkId}")
    public Optional<AhjLink> updatePermitLink(@PathVariable Long ahjId,
                                              @PathVariable Long permitId,
                                              @PathVariable Long linkId,
                                              @RequestBody AhjLink link) {
        return ahjPermitService.savePermitLink(ahjId, permitId, linkId, link);
    }

    @DeleteMapping(value = "/{permitId}/links/{linkId}")
    public void deletePermitLink(@PathVariable Long ahjId,
                                 @PathVariable Long permitId,
                                 @PathVariable Long linkId) {
        ahjPermitService.deletePermitLink(ahjId, permitId, linkId);
    }
}
