package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj;

import com.albatross.api.v1.company.blueraven.enums.AhjType;
import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.company.blueraven.services.featDB.AhjNewHomeService;
import com.albatross.api.v1.company.blueraven.services.featDB.AhjService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PostAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@RestController
@Hidden
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/featDb/ahj/{ahjId}/newHome")
public class AhjNewHomeController {

    private final AhjNewHomeService ahjNewHomeService;
    private final AhjService ahjService;

    @PostAuthorize("returnObject.get().getArchived() == true && hasFeatureAccessLevel('AHJ_ADMIN') || returnObject.get().getArchived() == false")
    @GetMapping(value = "")
    public Optional<AhjNewHomeDetail> getAhjNewHomeDetail(@PathVariable Long ahjId) {
        return ahjNewHomeService.getAhjNewHomeDetailByAhjId(ahjId);
    }

    @PostMapping(value = "")
    public Optional<AhjNewHome> createAhjNewHome(@PathVariable Long ahjId,
                                                       @RequestBody AhjNewHome newHome) {
        return ahjNewHomeService.saveAhjNewHome(ahjId, null, newHome, true);
    }

    @PutMapping(value = "/{id}")
    public Optional<AhjNewHome> updateAhjNewHome(@PathVariable Long ahjId,
                                                       @PathVariable Long id,
                                                       @RequestBody AhjNewHome newHome) {
        return ahjNewHomeService.saveAhjNewHome(ahjId, id, newHome, true);
    }

    @GetMapping(value = "/searchAhjsByState/{stateId}")
    public List<AhjNewHome> searchAhjsByState(@PathVariable Long stateId) {
        return ahjNewHomeService.searchAhjsByState(stateId);
    }

    @GetMapping(value = "/searchAhjsByMetro/{metroId}")
    public List<AhjNewHome> searchAhjsByMetro(@PathVariable Long metroId) {
      return ahjNewHomeService.searchAhjsByMetro(metroId);
    }

    // CONTACTS
    @PostMapping(value = "/{newHomeId}/contacts")
    public Optional<FeatDbContact> addAhjContact(@PathVariable Long newHomeId,
                                                 @RequestBody FeatDbContact featDbContact) {
      return ahjService.saveAhjContact(newHomeId, null, featDbContact, AhjType.NEW_HOME);
    }

    @PutMapping(value = "/{newHomeId}/contacts/{contactId}")
    public Optional<FeatDbContact> updateAhjContact(@PathVariable Long newHomeId,
                                                    @PathVariable Long contactId,
                                                    @RequestBody FeatDbContact featDbContact) {
      return ahjService.saveAhjContact(newHomeId, contactId, featDbContact, AhjType.NEW_HOME);
    }

    @PutMapping(value = "/{newHomeId}/contacts/{contactId}/archive")
    public void removeAhjContact(@PathVariable Long newHomeId,
                                 @PathVariable Long contactId) {
      ahjService.deleteAhjContact(newHomeId, contactId);
    }

    // LINKS
    @PostMapping(value = "/{newHomeId}/links")
    public Optional<FeatDbLink> addNewHomeLink(@PathVariable Long ahjId,
                                                  @PathVariable Long newHomeId,
                                                  @RequestBody FeatDbLink link) {
      return ahjNewHomeService.saveNewHomeLink(ahjId, newHomeId, null, link);
    }

    @PutMapping(value = "/{newHomeId}/links/{linkId}")
    public Optional<FeatDbLink> updateNewHomeLink(@PathVariable Long ahjId,
                                                     @PathVariable Long newHomeId,
                                                     @PathVariable Long linkId,
                                                     @RequestBody FeatDbLink link) {
      return ahjNewHomeService.saveNewHomeLink(ahjId, newHomeId, linkId, link);
    }

    @PutMapping(value = "/{newHomeId}/links/{linkId}/archive")
    public void deleteNewHomeLink(@PathVariable Long ahjId,
                                     @PathVariable Long newHomeId,
                                     @PathVariable Long linkId) {
      ahjNewHomeService.deleteNewHomeLink(ahjId, newHomeId, linkId);
    }

    @GetMapping(value="/history")
    public List<DatabaseHistory> getAhjNewHomeHistory(@PathVariable Long ahjId) {
      return ahjNewHomeService.getAhjNewHomeHistory(ahjId);
    }
}
