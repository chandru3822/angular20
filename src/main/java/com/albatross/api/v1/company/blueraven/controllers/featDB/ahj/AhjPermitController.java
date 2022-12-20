package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj;

import com.albatross.api.v1.company.blueraven.enums.AhjType;
import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.company.blueraven.services.featDB.AhjPermitService;
import com.albatross.api.v1.company.blueraven.services.featDB.AhjService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-18.
 */
@RestController
@Hidden
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/featDb/ahj/{ahjId}/permit")
public class AhjPermitController {

    private final AhjPermitService ahjPermitService;

    @Autowired
    private AhjService ahjService;

    @GetMapping(value = "")
    public Optional<AhjPermitDetail> getAhjPermitDetail(@PathVariable Long ahjId) {
        return ahjPermitService.getAhjPermitDetailByAhjId(ahjId);
    }

    @PostMapping(value = "")
    public Optional<AhjPermitDetail> createAhjPermit(@PathVariable Long ahjId,
                                                     @RequestBody AhjPermit permit) {
        return ahjPermitService.saveAhjPermit(ahjId, null, permit, true);
    }

    @PutMapping(value = "/{permitId}")
    public Optional<AhjPermitDetail> updateAhjPermit(@PathVariable Long ahjId,
                                                     @PathVariable Long permitId,
                                                     @RequestBody AhjPermit permit) {
        return ahjPermitService.saveAhjPermit(ahjId, permitId, permit, true);
    }

    @GetMapping(value = "/searchAhjsByState/{stateId}")
    public List<AhjPermit> searchAhjsByState(@PathVariable Long stateId) {
        return ahjPermitService.searchAhjsByState(stateId);
    }

    // CONTACTS
    @PostMapping(value = "/{permitId}/contacts")
    public Optional<FeatDbContact> addAhjContact(@PathVariable Long permitId,
                                                 @RequestBody FeatDbContact featDbContact) {
        return ahjService.saveAhjContact(permitId, null, featDbContact, AhjType.PERMIT);
    }

    @PutMapping(value = "/{permitId}/contacts/{contactId}")
    public Optional<FeatDbContact> updateAhjContact(@PathVariable Long permitId,
                                                    @PathVariable Long contactId,
                                                    @RequestBody FeatDbContact featDbContact) {
        return ahjService.saveAhjContact(permitId, contactId, featDbContact, AhjType.PERMIT);
    }

    @PutMapping(value = "/{permitId}/contacts/{contactId}/archive")
    public void deleteAhjContact(@PathVariable Long permitId,
                                 @PathVariable Long contactId) {
        ahjService.deleteAhjContact(permitId, contactId);
    }

    // LINKS
    @PostMapping(value = "/{permitId}/links")
    public Optional<FeatDbLink> addPermitLink(@PathVariable Long ahjId,
                                              @PathVariable Long permitId,
                                              @RequestBody FeatDbLink link) {
        return ahjPermitService.savePermitLink(ahjId, permitId, null, link);
    }

    @PutMapping(value = "/{permitId}/links/{linkId}")
    public Optional<FeatDbLink> updatePermitLink(@PathVariable Long ahjId,
                                                 @PathVariable Long permitId,
                                                 @PathVariable Long linkId,
                                                 @RequestBody FeatDbLink link) {
        return ahjPermitService.savePermitLink(ahjId, permitId, linkId, link);
    }

    @PutMapping(value = "/{permitId}/links/{linkId}/archive")
    public void deletePermitLink(@PathVariable Long ahjId,
                                 @PathVariable Long permitId,
                                 @PathVariable Long linkId) {
        ahjPermitService.deletePermitLink(ahjId, permitId, linkId);
    }
}
