package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.AhjUtility;
import com.albatross.api.v1.company.blueraven.models.AhjUtilityDetail;
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

    @RequestMapping(value = "/list/all", method = RequestMethod.GET)
    public List<AhjUtility> getAllAhjUtilities() {
        return ahjUtilityService.getAllAhjUtilities();
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    public Optional<AhjUtilityDetail> getUtilityById(@PathVariable Long id) {
        return ahjUtilityService.getUtilityById(id);
    }

    @RequestMapping(value = "", method = RequestMethod.POST)
    public Optional<AhjUtilityDetail> createUtility(@RequestBody AhjUtility utility) {
        return ahjUtilityService.updateUtility(utility);
    }

    @RequestMapping(value = "/simpleUpdate", method = RequestMethod.PUT)
    public Optional<AhjUtilityDetail> updateSimple(@RequestBody AhjUtility utility) {
        return ahjUtilityService.simpleUpdateUtility(utility);
    }

    @RequestMapping(value = "", method = RequestMethod.PUT)
    public Optional<AhjUtilityDetail> editUtility(@RequestBody AhjUtility utility) {
        return ahjUtilityService.updateUtility(utility);
    }
}