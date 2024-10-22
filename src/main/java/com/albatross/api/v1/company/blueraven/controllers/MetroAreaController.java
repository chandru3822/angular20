package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CustomFieldValue;
import com.albatross.api.v1.company.blueraven.models.MetroArea;
import com.albatross.api.v1.company.blueraven.services.MetroAreaService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/metro")
@RequiredArgsConstructor
public class MetroAreaController {

    private final MetroAreaService metroAreaService;

    @GetMapping(value = "/getActive")
    public List<MetroArea> getAllActiveMetroAreas() {
        return metroAreaService.getAllActiveMetroAreas();
    }


    @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
    @GetMapping(value = "/getAllowedModules/{metroId}")
    public List<CustomFieldValue> getAllowedModulesForMetroArea(@PathVariable Long metroId){
        return metroAreaService.getAllowedModulesForMetroArea(metroId);
    }

}
