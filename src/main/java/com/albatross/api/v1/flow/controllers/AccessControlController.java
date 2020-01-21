package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.services.AccessControlService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by randanunn 12/17/19
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/accessControl")
public class AccessControlController {

  @Autowired
  private AccessControlService accessControlService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<FeatureAccessControl> getAccessControlList() {
    return accessControlService.getAccessControlList();
  }


}
