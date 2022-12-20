package com.albatross.api.v1.company.blueraven.controllers.featDB.utility;

import com.albatross.api.v1.company.blueraven.models.featDB.FeatDbContact;
import com.albatross.api.v1.company.blueraven.models.featDB.FeatDbLink;
import com.albatross.api.v1.company.blueraven.models.featDB.Utility;
import com.albatross.api.v1.company.blueraven.models.featDB.UtilityDetail;
import com.albatross.api.v1.company.blueraven.services.featDB.UtilityService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@RestController
@Hidden
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/featDb/utility")
public class UtilityController {

  private final UtilityService utilityService;

    @GetMapping(value = "/list/all")
    public List<Utility> getAllUtilities() {
        return utilityService.getAllUtilities();
    }

    @GetMapping(value = "/{id}")
    public Optional<UtilityDetail> getUtilityById(@PathVariable Long id) {
        return utilityService.getUtilityById(id);
    }

    @PostMapping(value = "")
    public Optional<UtilityDetail> createUtility(@RequestBody Utility utility) {
        return utilityService.updateUtility(utility);
    }

    @PutMapping(value = "/simpleUpdate")
    public Optional<UtilityDetail> simpleUpdate(@RequestBody Utility utility) {
        return utilityService.simpleUpdate(utility);
    }

    @PutMapping(value = "")
    public Optional<UtilityDetail> editUtility(@RequestBody Utility utility) {
        return utilityService.updateUtility(utility);
    }

    // CONTACTS
    @PostMapping(value = "/{utilityId}/contacts")
    public Optional<FeatDbContact> addUtilityContact(@PathVariable Long utilityId,
                                                     @RequestBody FeatDbContact utilityContact) {
        return utilityService.saveUtilityContact(utilityId, null, utilityContact);
    }

    @PutMapping(value = "/{utilityId}/contacts/{contactId}")
    public Optional<FeatDbContact> updateUtilityContact(@PathVariable Long utilityId,
                                                        @PathVariable Long contactId,
                                                        @RequestBody FeatDbContact utilityContact) {
        return utilityService.saveUtilityContact(utilityId, contactId, utilityContact);
    }

    @PutMapping(value = "/contacts/{contactId}/archive")
    public void deleteUtilityContact(@PathVariable Long contactId) {
        utilityService.deleteUtilityContact(contactId);
    }

    // LINKS
    @PostMapping(value = "/{utilityId}/links")
    public Optional<FeatDbLink> addUtilityLink(@PathVariable Long utilityId,
                                               @RequestBody FeatDbLink link) {
        return utilityService.saveUtilityLink(utilityId, null, link);
    }

    @PutMapping(value = "/{utilityId}/links/{linkId}")
    public Optional<FeatDbLink> updateUtilityLink(@PathVariable Long utilityId,
                                                  @PathVariable Long linkId,
                                                  @RequestBody FeatDbLink link) {
        return utilityService.saveUtilityLink(utilityId, linkId, link);
    }

    @PutMapping(value = "/links/{linkId}/archive")
    public void deleteUtilityLink(@PathVariable Long linkId) {
        utilityService.deleteUtilityLink(linkId);
    }
}
