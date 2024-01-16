package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.services.AccessControlService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/accessControl")
@RequiredArgsConstructor
public class AccessControlController {

  private final AccessControlService accessControlService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<FeatureAccessControl> getAccessControlList() {
    return accessControlService.getAccessControlList();
  }
}
