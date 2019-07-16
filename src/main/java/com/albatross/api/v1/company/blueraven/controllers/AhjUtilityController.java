package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.AhjUtility;
import com.albatross.api.v1.company.blueraven.services.AhjUtilityService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
}