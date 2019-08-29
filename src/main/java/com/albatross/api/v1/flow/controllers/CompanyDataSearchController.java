package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Project;
import com.albatross.api.v1.flow.services.ProjectService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/{companyId}")
public class CompanyDataSearchController {

  private final ProjectService projectService;

  @GetMapping(value = "/projects", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Project>> getProjectsForCustomer(@PathVariable Long companyId, @RequestParam Long customerId) {
    return new ResponseEntity<>(projectService.getProjectsForCustomer(companyId, customerId), HttpStatus.OK);
  }
}
