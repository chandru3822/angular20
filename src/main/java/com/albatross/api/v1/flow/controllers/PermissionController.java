package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Permission;
import com.albatross.api.v1.flow.services.PermissionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn 12/17/19
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/permission")
public class PermissionController {

  @Autowired
  private PermissionService permissionService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Permission> getPermissionsForCompany() {
    return permissionService.getPermissionsForCompany();
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Permission savePermission(@RequestBody Permission p) {
    return permissionService.savePermission(p);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Permission getPermission(@PathVariable Long id) {
    return permissionService.getPermission(id);
  }

}
