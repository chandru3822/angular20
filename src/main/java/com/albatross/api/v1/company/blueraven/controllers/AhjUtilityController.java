package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.ahj.AhjUtility;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjUtilityDetail;
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
    public Optional<AhjUtilityDetail> updateSimple(@RequestBody AhjUtility utility) {
        return ahjUtilityService.simpleUpdateUtility(utility);
    }

    @PutMapping(value = "")
    public Optional<AhjUtilityDetail> editUtility(@RequestBody AhjUtility utility) {
        return ahjUtilityService.updateUtility(utility);
    }
}
