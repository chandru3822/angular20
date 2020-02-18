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
    @PostMapping(value = "/{id}/contacts")
    public Optional<AhjContact> addUtilityContact(@PathVariable Long id, @RequestBody AhjContact utilityContact) {
        return ahjUtilityService.addUtilityContact(id, utilityContact);
    }

    @PutMapping(value = "/contacts/{contactId}")
    public Optional<AhjContact> updateUtilityContact(@PathVariable Long contactId, @RequestBody AhjContact utilityContact) {
        return ahjUtilityService.updateUtilityContact(contactId, utilityContact);
    }

    @PutMapping(value = "/contacts/{contactId}/archive")
    public void deleteUtilityContact(@PathVariable Long contactId) {
        ahjUtilityService.deleteUtilityContact(contactId);
    }

    // CHECKLISTS


    // LINKS

}
