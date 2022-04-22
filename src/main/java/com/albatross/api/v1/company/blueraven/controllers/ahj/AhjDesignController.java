package com.albatross.api.v1.company.blueraven.controllers.ahj;

import com.albatross.api.v1.company.blueraven.models.ahj.AhjDesign;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjDesignDetail;
import com.albatross.api.v1.company.blueraven.services.ahj.AhjDesignService;
import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/ahj/{ahjId}/design")
public class AhjDesignController {
    @Autowired
    private AhjDesignService ahjDesignService;

    @GetMapping(value = "")
    public Optional<AhjDesignDetail> getAhjDesignDetail(@PathVariable Long ahjId) {
        return ahjDesignService.getAhjDesignDetailByAhjId(ahjId);
    }

    @PostMapping(value = "")
    public Optional<AhjDesignDetail> createAhjDesign(@PathVariable Long ahjId,
                                               @RequestBody AhjDesign design) {
        return ahjDesignService.saveAhjDesign(ahjId, null, design, true);
    }

    @PutMapping(value = "/{id}")
    public Optional<AhjDesignDetail> updateAhjDesign(@PathVariable Long ahjId,
                                                     @PathVariable Long id,
                                                     @RequestBody AhjDesign design) {
        return ahjDesignService.saveAhjDesign(ahjId, id, design, true);
    }

    @GetMapping(value = "/searchAhjsByState/{stateId}")
    public List<AhjDesign> searchAhjsByState(@PathVariable Long stateId) {
        return ahjDesignService.searchAhjsByState(stateId);
    }
}
