package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.enums.ObjectType;
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

  @GetMapping(value = "/customer", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getCustomerCustomFieldValues(@PathVariable Long companyId,
                                             @RequestParam Long primaryId) {
    return customFieldValueService.getCustomFieldValuesByPrimaryIdAndType(companyId, primaryId, ObjectType.CUSTOMER.id);
  }

  //@humes  
  @GetMapping(value = "/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getProjectCustomFieldValues(@PathVariable Long companyId,
                                            @RequestParam Long primaryId) {
    return customFieldValueService.getCustomFieldValuesByPrimaryIdAndType(companyId, primaryId, ObjectType.PROJECT.id);
  }
}
