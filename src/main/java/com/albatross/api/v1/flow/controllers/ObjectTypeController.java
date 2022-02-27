package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.WhiteListType;
import com.albatross.api.v1.flow.model.CompanyObjectType;
import com.albatross.api.v1.flow.services.ObjectTypeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/objectType")
public class ObjectTypeController {

  private final ObjectTypeService objectTypeService;

  @GetMapping(value = "/getCompanyObjectTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyObjectType> getCompanyObjectTypes() {
    return objectTypeService.getCompanyObjectTypes();
  }

  @GetMapping(value = "/getByType/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<CompanyObjectType> getCustomFieldObjectTypeDetail(@PathVariable Long typeId) {
    return objectTypeService.getCompanyObjectTypeDetail(typeId);
  }

  @PutMapping(value = "/saveStatusReadOnlyAndWhiteList", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveStatusAndWhiteList(@RequestParam(required = false) Boolean savePositions,
                                         @RequestBody CompanyObjectType objectType) {
    objectTypeService.saveTypeAndWhiteList(objectType, true, savePositions, WhiteListType.PROJECT_STATUS_READ_ONLY.id);
  }

  @PutMapping(value = "/saveOwnerReadOnlyAndWhiteList", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveOwnerReadOnlyAndWhiteList(@RequestParam(required = false) Boolean savePositions,
                                            @RequestBody CompanyObjectType objectType) {
    //get the correct whitelist type id and then save
    Long whiteListTypeId = objectType.getObjectTypeId().equals(ObjectType.PROJECT.id) ? WhiteListType.PROJECT_OWNER_READ_ONLY.id : WhiteListType.CONTACT_OWNER_READ_ONLY.id;
    objectTypeService.saveTypeAndWhiteList(objectType, false, savePositions, whiteListTypeId);
  }

}
