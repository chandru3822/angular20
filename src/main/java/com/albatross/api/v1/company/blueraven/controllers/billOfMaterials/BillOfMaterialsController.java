package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials;

import com.albatross.api.exception.ApiException;
import com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.models.BillOfMaterialsPart;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.InputStream;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/bom", produces = MediaType.APPLICATION_JSON_VALUE)
public class BillOfMaterialsController {

    private final BillOfMaterialsService billOfMaterialsService;
    private static final String CACHE_CONTROL_VALUE = "no-store, no-cache, must-revalidate, max-age=0";


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

    @PostMapping(value="/{projectId}/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    @PreAuthorize("hasFeatureAccessLevel('BILL_OF_MATERIALS_EDIT')")
    public ResponseEntity<StreamingResponseBody> getMaterialListPDF(@PathVariable Long projectId, @RequestBody List<BillOfMaterialsPart> parts, HttpServletResponse response) {
        final StreamingResponseBody responseBody = outputStream -> {
            try{
                Resource result = billOfMaterialsService.generateMaterialListPDF(projectId, parts);

                response.addHeader(HttpHeaders.CACHE_CONTROL, CACHE_CONTROL_VALUE);
                response.addHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PDF_VALUE);
                response.addHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(result.contentLength()));
                try (InputStream inputStream = result.getInputStream()) {
                    IOUtils.copy(inputStream, outputStream);
                }
            } catch (Exception e){
                throw new ApiException(e);
            }
        };
        return ResponseEntity.ok(responseBody);

    }
}
