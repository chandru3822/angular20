package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.MetroArea;
import com.albatross.api.v1.company.blueraven.services.MetroAreaService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
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
}
