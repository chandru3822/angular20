package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Role;
import com.albatross.api.v1.flow.services.RoleService;
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
@RequestMapping(value = "/api/v1/flow/role")
public class RoleController {

  @Autowired
  private RoleService roleService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Role> getRolesForCompany() {
    return roleService.getRolesForCompany();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Role getRole(@PathVariable Long id) {
    return roleService.getRole(id);
  }

  @PostMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
  public void insertRole(@RequestBody Role role) {
    roleService.insertRole(role);
  }

  @PutMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateRole(@RequestBody Role role) {
    roleService.updateRole(role);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateRole(@PathVariable Long id) {
    roleService.deleteRole(id);
  }

}
