package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.AhjInspection;
import com.albatross.api.v1.company.blueraven.models.AhjInspectionDetail;
import com.albatross.api.v1.company.blueraven.services.AhjInspectionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/ahj/{ahjId}/inspection")
public class AhjInspectionController {
    @Autowired
    private AhjInspectionService ahjInspectionService;

    @GetMapping(value = "")
    public Optional<AhjInspectionDetail> getAhjInspectionDetail(@PathVariable Long ahjId) {
        return ahjInspectionService.getAhjInspectionDetailByAhjId(ahjId);
    }

    @PostMapping(value = "")
    public Optional<AhjInspection> createAhjInspection(@PathVariable Long ahjId,
                                                       @RequestBody AhjInspection inspection) {
        return ahjInspectionService.createAhjInspection(ahjId, inspection);
    }

    @PutMapping(value = "/{id}")
    public Optional<AhjInspection> updateAhjInspection(@PathVariable Long ahjId,
                                                       @PathVariable Long id,
                                                       @RequestBody AhjInspection inspection) {
        return ahjInspectionService.saveAhjInspection(ahjId, id, inspection);
    }
}
