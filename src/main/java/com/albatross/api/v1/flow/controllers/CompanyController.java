package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Company;
import com.albatross.api.v1.flow.services.CompanyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/companies")
public class CompanyController {

  private final CompanyService companyService;

  @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Company>> getAllCompanies() {
    return new ResponseEntity<>(companyService.getCompanies(), HttpStatus.OK);
  }

  @GetMapping(value = "/assignedToUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Company>> getAssignedCompaniesToUser(@RequestParam(required = false) Long userId) {
    return new ResponseEntity<>(companyService.getCompaniesAssignedToUser(userId), HttpStatus.OK);
  }

  @GetMapping(value = "/availableForUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Company>> getAllCompaniesForUser(@RequestParam(required = false) Long userId) {
    return new ResponseEntity<>(companyService.getCompaniesAvailableForUser(userId), HttpStatus.OK);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Company> getCompany(@PathVariable Long id) {
    return companyService.getCompany(id)
      .map(ResponseEntity::ok)
      .orElse(ResponseEntity.notFound().build());
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Company> saveCompany(@RequestBody Company company) {
    return companyService.saveCompany(company)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
  }


}
