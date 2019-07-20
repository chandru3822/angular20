package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.enums.AhjType;
import com.albatross.api.v1.company.blueraven.models.*;
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

    @RequestMapping(value = "", method = RequestMethod.GET)
    public Optional<AhjPermitDetail> getAhjPermitDetail(@PathVariable Long ahjId) {
        return ahjPermitService.getAhjPermitDetailByAhjId(ahjId);
    }

    @RequestMapping(value = "", method = RequestMethod.POST)
    public Optional<AhjPermitDetail> createAhjPermit(@PathVariable Long ahjId,
                                                     @RequestBody AhjPermit permit) {
        return ahjPermitService.createAhjPermit(ahjId, permit);
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.PUT)
    public Optional<AhjPermitDetail> updateAhjPermit(@PathVariable Long ahjId,
                                                     @PathVariable Long id,
                                                     @RequestBody AhjPermit permit) {
        return ahjPermitService.saveAhjPermit(ahjId, id, permit);
    }

    // CONTACTS
    @RequestMapping(value = "/{id}/contacts", method = RequestMethod.POST)
    public Optional<AhjContact> addAhjContact(@PathVariable Long id,
                                              @RequestBody AhjContact ahjContact) {
        return ahjService.createAhjContact(id, ahjContact, AhjType.PERMIT);
    }

    @RequestMapping(value = "/{id}/contacts/{contactId}", method = RequestMethod.PUT)
    public Optional<AhjContact> updateAhjContact(@PathVariable Long id,
                                                 @PathVariable Long contactId,
                                                 @RequestBody AhjContact ahjContact) {
        return ahjService.saveAhjContact(id, contactId, ahjContact, AhjType.PERMIT);
    }

    @RequestMapping(value = "/{id}/contacts/{contactId}", method = RequestMethod.DELETE)
    public void removeAhjContact(@PathVariable Long id, @PathVariable Long contactId) {
        ahjService.deleteAhjContact(id, contactId);
    }
}