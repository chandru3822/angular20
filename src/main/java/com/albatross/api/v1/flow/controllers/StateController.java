package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyState;
import com.albatross.api.v1.flow.services.StateService;
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
@RequestMapping(value = "/api/v1/flow/state")
public class StateController {

  @Autowired
  private StateService stateService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyState> getAllStates() {
    return stateService.getAllStates();
  }

  @GetMapping(value = "/company", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyState> getAllCompanyStates() {
    return stateService.getAllCompanyStates();
  }

  @PutMapping(value = "/saveCompanyState", produces = MediaType.APPLICATION_JSON_VALUE)
  public CompanyState saveCompanyState(@RequestBody CompanyState state) {
    return stateService.saveCompanyState(state);
  }

  @DeleteMapping(value = "/companyState/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCompanyState(@PathVariable Long id) {
    stateService.deleteCompanyState(id);
  }

  @GetMapping(value = "/active", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyState> getActiveStatesByCompany() {
    return stateService.getActiveStatesByCompany();
  }

  @GetMapping(value = "/activeByHierarchy", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyState> getActiveStatesByHierarchy() {
    return stateService.getActiveStatesByHierarchy();
  }

}
