package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.AhjDesign;
import com.albatross.api.v1.company.blueraven.models.AhjDesignDetail;
import com.albatross.api.v1.company.blueraven.services.AhjDesignService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/ahj/{ahjId}/design")
public class AhjDesignController {
    @Autowired
    private AhjDesignService ahjDesignService;

    @GetMapping(value = "")
    public Optional<AhjDesignDetail> getAhjDesignDetail(@PathVariable Long ahjId) {
        return ahjDesignService.getAhjDesignDetailByAhjId(ahjId);
    }

    @PostMapping(value = "")
    public Optional<AhjDesign> createAhjDesign(@PathVariable Long ahjId,
                                               @RequestBody AhjDesign design) {
        return ahjDesignService.createAhjDesign(ahjId, design);
    }

    @PutMapping(value = "/{id}")
    public Optional<AhjDesign> updateAhjDesign(@PathVariable Long ahjId,
                                                     @PathVariable Long id,
                                                     @RequestBody AhjDesign design) {
        return ahjDesignService.saveAhjDesign(ahjId, id, design);
    }
}
