package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.SystemList;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.SystemListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/systemList", produces = MediaType.APPLICATION_JSON_VALUE)
public class SystemListController {

  private final SystemListService systemListService;
  private final SecurityService securityService;

  @GetMapping(value = "")
  public List<SystemList> getSystemListsForCompany() {
    return systemListService.getSystemListsForCompany();
  }

  @GetMapping(value = "/{id}/options")
  public List<ListOfValue> getSystemListOptionsForCompany(
      @PathVariable("id") Long typeId,
      @RequestParam Boolean subOptions,
      @RequestParam(required = false) List<Long> systemListOptionIds) {
    User currentUser = securityService.getCurrentUser();
    return systemListService.getSystemListOptionsForCompany(
        typeId, subOptions, systemListOptionIds, currentUser.getCompanyId());
  }
}
