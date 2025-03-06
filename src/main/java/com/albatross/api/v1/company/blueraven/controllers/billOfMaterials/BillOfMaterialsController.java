package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials;

import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPart;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/bom", produces = MediaType.APPLICATION_JSON_VALUE)
public class BillOfMaterialsController {

    private final BillOfMaterialsService billOfMaterialsService;

    @PostMapping(value="/{projectId}/parts")
    public List<BillOfMaterialsPart> upsertBomParts(
            @PathVariable Long projectId,
            @RequestBody List<BillOfMaterialsPart> parts
            ){
        return billOfMaterialsService.upsertBomParts(projectId, parts);
    }

    @GetMapping(value="/{projectId}")
    public List<BillOfMaterialsPart> getBomByTypeForProject(
            @PathVariable Long projectId
    ){
        return billOfMaterialsService.getBomForProject(projectId);
    }

    @DeleteMapping(value="/{projectId}")
    public void deleteBillOfMaterialsAllParts(@PathVariable Long projectId){
        billOfMaterialsService.deleteBillOfMaterialsAllParts(projectId);
    }
}
