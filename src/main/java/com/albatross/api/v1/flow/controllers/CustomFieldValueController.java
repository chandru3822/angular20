package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.services.CustomFieldValueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/{companyId}/customFieldValues")
public class CustomFieldValueController {

    private final CustomFieldValueService customFieldValueService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public String getCustomFieldValuesByPrimaryIdAndType(@PathVariable Long companyId,
                                                                         @RequestParam Long primaryId,
                                                                         @RequestParam Long objectTypeId) {
      // this function name is a special gift for humes
      return customFieldValueService.getCustomFieldValuesByPrimaryIdAndType(companyId, primaryId, objectTypeId);
    }

}
