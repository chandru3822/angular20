package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CompanyObjectType;
import com.albatross.api.v1.company.blueraven.services.BlueravenObjectTypeService;
import com.albatross.api.v1.flow.model.CombinedStepAndType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/objectType")
public class BlueRavenObjectTypeController {

  private final BlueravenObjectTypeService objectTypeService;

  @GetMapping(value = "/getCustomFieldObjectTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyObjectType> getCustomFieldObjectTypes() {
    return objectTypeService.getCompanyObjectTypes();
  }

  @GetMapping(value = "/getByType/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<CompanyObjectType> getCustomFieldObjectTypeDetail(@PathVariable Long typeId) {
    return objectTypeService.getCompanyObjectTypeDetail(typeId);
  }

  @GetMapping(value = "/{typeId}/getParentObjectsWithTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CombinedStepAndType> getParentObjectsWithTypes(@PathVariable Long typeId) {
    return objectTypeService.getParentObjectsWithTypes(typeId);
  }

}
