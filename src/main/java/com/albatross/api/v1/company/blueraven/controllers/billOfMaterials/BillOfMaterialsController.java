package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials;

import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterials;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPart;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/brs/bom", produces = MediaType.APPLICATION_JSON_VALUE)
public class BillOfMaterialsController {

    private final BillOfMaterialsService billOfMaterialsService;

    @PostMapping("/{projectId}/{bomTypeId}")
    public Optional<BillOfMaterials> createBillOfMaterials(
            @PathVariable Long projectId,
            @PathVariable Long bomTypeId,
            @RequestParam List<BillOfMaterialsPart> parts
    ){
        return billOfMaterialsService.createBomForProject(projectId, bomTypeId, parts);
    }

    @PutMapping(value="/{bomId}/parts")
    public Optional<BillOfMaterials> updateBomParts(
            @PathVariable Long bomId,
            @RequestParam List<BillOfMaterialsPart> parts
            ){
        return billOfMaterialsService.updateBomParts(bomId, parts);
    }

    @GetMapping(value="/{projectId}/{bomTypeId}")
    public Optional<BillOfMaterials> getBomByTypeForProject(
            @PathVariable Long projectId,
            @PathVariable Long bomTypeId
    ){
        return billOfMaterialsService.getBomByTypeForProject(projectId, bomTypeId);
    }

    @DeleteMapping(value="/{bomId}")
    public void deleteBillOfMaterials(@PathVariable Long bomId){
        billOfMaterialsService.deleteBillOfMaterials(bomId);
    }
}
