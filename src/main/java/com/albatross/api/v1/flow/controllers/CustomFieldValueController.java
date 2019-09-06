package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/{companyId}/customFieldValues")
public class CustomFieldValueController {

  private final CustomFieldValueService customFieldValueService;

  @GetMapping(value = "/customer", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getTestCustomFieldValues(@PathVariable Long companyId,
                                                         @RequestParam Long primaryId) {
    return customFieldValueService.getCustomerCustomValues(companyId, primaryId);
  }


}
