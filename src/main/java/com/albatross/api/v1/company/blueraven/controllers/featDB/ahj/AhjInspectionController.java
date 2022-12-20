package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj;

import com.albatross.api.v1.company.blueraven.enums.AhjType;
import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.company.blueraven.services.featDB.AhjInspectionService;
import com.albatross.api.v1.company.blueraven.services.featDB.AhjService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@RestController
@Hidden
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/featDb/ahj/{ahjId}/inspection")
public class AhjInspectionController {

    private final AhjInspectionService ahjInspectionService;

    @Autowired
    private AhjService ahjService;

    @GetMapping(value = "")
    public Optional<AhjInspectionDetail> getAhjInspectionDetail(@PathVariable Long ahjId) {
        return ahjInspectionService.getAhjInspectionDetailByAhjId(ahjId);
    }

    @PostMapping(value = "")
    public Optional<AhjInspection> createAhjInspection(@PathVariable Long ahjId,
                                                       @RequestBody AhjInspection inspection) {
        return ahjInspectionService.saveAhjInspection(ahjId, null, inspection, true);
    }

    @PutMapping(value = "/{id}")
    public Optional<AhjInspection> updateAhjInspection(@PathVariable Long ahjId,
                                                       @PathVariable Long id,
                                                       @RequestBody AhjInspection inspection) {
        return ahjInspectionService.saveAhjInspection(ahjId, id, inspection, true);
    }

    @GetMapping(value = "/searchAhjsByState/{stateId}")
    public List<AhjInspection> searchAhjsByState(@PathVariable Long stateId) {
        return ahjInspectionService.searchAhjsByState(stateId);
    }

    // CONTACTS
    @PostMapping(value = "/{inspectionId}/contacts")
    public Optional<FeatDbContact> addAhjContact(@PathVariable Long inspectionId,
                                                 @RequestBody FeatDbContact featDbContact) {
      return ahjService.saveAhjContact(inspectionId, null, featDbContact, AhjType.INSPECTION);
    }

    @PutMapping(value = "/{inspectionId}/contacts/{contactId}")
    public Optional<FeatDbContact> updateAhjContact(@PathVariable Long inspectionId,
                                                    @PathVariable Long contactId,
                                                    @RequestBody FeatDbContact featDbContact) {
      return ahjService.saveAhjContact(inspectionId, contactId, featDbContact, AhjType.INSPECTION);
    }

    @PutMapping(value = "/{inspectionId}/contacts/{contactId}/archive")
    public void removeAhjContact(@PathVariable Long inspectionId,
                                 @PathVariable Long contactId) {
      ahjService.deleteAhjContact(inspectionId, contactId);
    }

    // LINKS
    @PostMapping(value = "/{inspectionId}/links")
    public Optional<FeatDbLink> addInspectionLink(@PathVariable Long ahjId,
                                                  @PathVariable Long inspectionId,
                                                  @RequestBody FeatDbLink link) {
      return ahjInspectionService.saveInspectionLink(ahjId, inspectionId, null, link);
    }

    @PutMapping(value = "/{inspectionId}/links/{linkId}")
    public Optional<FeatDbLink> updateInspectionLink(@PathVariable Long ahjId,
                                                     @PathVariable Long inspectionId,
                                                     @PathVariable Long linkId,
                                                     @RequestBody FeatDbLink link) {
      return ahjInspectionService.saveInspectionLink(ahjId, inspectionId, linkId, link);
    }

    @PutMapping(value = "/{inspectionId}/links/{linkId}/archive")
    public void deleteInspectionLink(@PathVariable Long ahjId,
                                     @PathVariable Long inspectionId,
                                     @PathVariable Long linkId) {
      ahjInspectionService.deleteInspectionLink(ahjId, inspectionId, linkId);
    }

}
