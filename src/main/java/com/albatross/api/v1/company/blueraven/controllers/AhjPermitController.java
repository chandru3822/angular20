package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.*;
//import com.albatross.api.v1.company.blueraven.services.AhjService;
import com.albatross.api.v1.company.blueraven.services.AhjPermitService;
//import com.blueraven.view.api.v1.enums.AhjType;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-18.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/ahj/{ahjId}/permit")
public class AhjPermitController {
//    @Autowired
//    private AhjService ahjService;

    @Autowired
    private AhjPermitService ahjPermitService;

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public Optional<AhjPermitDetail> getAhjPermitDetail(@PathVariable Long ahjId) {
        return ahjPermitService.getAhjPermitDetailByAhjId(ahjId);
    }

//    @RequestMapping(value = "/", method = RequestMethod.POST)
//    public Optional<AhjPermitDetail> createAhjPermit(@PathVariable Long ahjId, @RequestBody AhjPermit permit) {
//        return ahjPermitService.createAhjPermit(ahjId, permit);
//    }
//
//    @RequestMapping(value = "/{id}", method = RequestMethod.PUT)
//    public Optional<AhjPermitDetail> updateAhjPermit(@PathVariable Long ahjId,
//                                                     @PathVariable Long id,
//                                                     @RequestBody AhjPermit permit) {
//        return ahjPermitService.saveAhjPermit(ahjId, id, permit);
//    }

//    /// LINKS
//    @RequestMapping(value = "/{id}/links", method = RequestMethod.POST)
//    public Optional<AhjLink> addPermitLink(@PathVariable Long ahjId,
//                                           @PathVariable Long id,
//                                           @RequestBody AhjLink link) {
//        return ahjPermitService.addPermitLink(ahjId, id, link);
//    }
//
//    @RequestMapping(value = "/{id}/links/{linkId}", method = RequestMethod.PUT)
//    public Optional<AhjLink> updatePermitLink(@PathVariable Long ahjId,
//                                              @PathVariable Long id,
//                                              @PathVariable Long linkId,
//                                              @RequestBody AhjLink link) {
//
//        return ahjPermitService.updatePermitLink(ahjId, id, linkId, link);
//    }
//
//    @RequestMapping(value = "/{id}/links/{linkId}", method = RequestMethod.DELETE)
//    public void deletePermitLink(@PathVariable Long ahjId,
//                                 @PathVariable Long id,
//                                 @PathVariable Long linkId) {
//
//        ahjPermitService.deletePermitLink(ahjId, id, linkId);
//    }
//
//    //    CONTACTS
//    @RequestMapping(value = "/{id}/contacts", method = RequestMethod.POST)
//    public Optional<AhjContact> addAhjContact(@PathVariable Long id, @RequestBody AhjContact ahjContact) {
//        return ahjService.createAhjContact(id, ahjContact, AhjType.PERMIT);
//    }
//
//    @RequestMapping(value = "/{id}/contacts/{contactId}", method = RequestMethod.PUT)
//    public Optional<AhjContact> updateAhjContact(@PathVariable Long id, @PathVariable Long contactId, @RequestBody AhjContact ahjContact) {
//        return ahjService.saveAhjContact(id, contactId, ahjContact, AhjType.PERMIT);
//    }
//
//    @RequestMapping(value = "/{id}/contacts/{contactId}", method = RequestMethod.DELETE)
//    public void removeAhjContact(@PathVariable Long id, @PathVariable Long contactId) {
//        ahjService.deleteAhjContact(id, contactId);
//    }
//
//
//    /// CHECKLIST
//    @RequestMapping(value = "/{id}/checklist", method = RequestMethod.POST)
//    public Optional<AhjChecklistItem> addPermitChecklistItem(@PathVariable Long ahjId,
//                                                             @PathVariable Long id,
//                                                             @RequestBody AhjChecklistItem item) {
//
//        return ahjService.createChecklistItem(ahjId, id, item, AhjType.PERMIT);
//    }
//
//    @RequestMapping(value = "/{id}/checklist/{checklistId}", method = RequestMethod.PUT)
//    public Optional<AhjChecklistItem> updatePermitChecklistItem(@PathVariable Long ahjId,
//                                                                @PathVariable Long id,
//                                                                @PathVariable Long checklistId,
//                                                                @RequestBody AhjChecklistItem item) {
//
//        return ahjService.saveChecklistItem(ahjId, id, checklistId, item, AhjType.PERMIT);
//    }
//
//    @RequestMapping(value = "/{id}/checklist/{checklistId}", method = RequestMethod.DELETE)
//    public void deletePermitChecklistItem(@PathVariable Long ahjId,
//                                          @PathVariable Long id,
//                                          @PathVariable Long checklistId) {
//
//        ahjService.deleteChecklistItem(ahjId, id, checklistId);
//    }
//
//
//    //    NOTES
//    @RequestMapping(value = "/{id}/notes", method = RequestMethod.POST)
//    public Optional<AhjNote> addAhjNote(@PathVariable Long id, @RequestBody AhjNote ahjNote) {
//        return ahjService.saveAhjNote(id, ahjNote, AhjType.PERMIT);
//    }
//
//    @RequestMapping(value = "/{id}/notes/{noteId}", method = RequestMethod.PUT)
//    public Optional<AhjNote> editAhjNote(@PathVariable Long id, @PathVariable Long noteId, @RequestBody AhjNote ahjNote) {
//        return ahjService.editAhjNote(noteId, ahjNote);
//    }
//
//    @RequestMapping(value = "/{id}/notes/{noteId}", method = RequestMethod.DELETE)
//    public void deleteAhjNote(@PathVariable Long id, @PathVariable Long noteId) {
//        ahjService.deleteAhjNote(noteId);
//    }
}