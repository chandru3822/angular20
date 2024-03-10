package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Role;
import com.albatross.api.v1.flow.services.RoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/role", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class RoleController {

  private final RoleService roleService;

  @GetMapping
  public List<Role> getRolesForCompany() {
    return roleService.getRolesForCompany();
  }

  @GetMapping(value = "/{id}")
  public Role getRole(@PathVariable Long id) {
    return roleService.getRole(id);
  }

  @PostMapping
  public Role insertRole(@RequestBody Role role) {
    return roleService.insertRole(role);
  }

  @PutMapping
  public Role updateRole(@RequestBody Role role) {
    return roleService.updateRole(role);
  }

  @DeleteMapping(value = "/{id}")
  public void deleteRole(@PathVariable Long id) {
    roleService.deleteRole(id);
  }

}
