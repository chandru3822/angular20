package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldGroupService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/customFieldGroup")
public class BlueravenCustomFieldGroupController {

  @Autowired
  private BlueravenCustomFieldGroupService customFieldGroupService;

  @GetMapping(value = "/getCustomFieldGroupAssignmentsByObjectType", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomFieldGroupAssignmentsByObjectTypeId (@RequestParam Long sourceId,
                                                                              @RequestParam Long objectTypeId) {
    return customFieldGroupService.getCustomFieldGroupAssignmentsByObjectTypeId(sourceId, objectTypeId);
  }
}
