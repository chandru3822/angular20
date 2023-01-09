package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Company;
import com.albatross.api.v1.flow.model.CompanyConfigurationValue;
import com.albatross.api.v1.flow.services.CompanyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/companies", produces = MediaType.APPLICATION_JSON_VALUE)
public class CompanyController {

  private final CompanyService companyService;

  @GetMapping
  public ResponseEntity<List<Company>> getAllCompanies() {
    return new ResponseEntity<>(companyService.getCompanies(), HttpStatus.OK);
  }

  @GetMapping(value = "/assignedToUser")
  public ResponseEntity<List<Company>> getAssignedCompaniesToUser(@RequestParam(required = false) Long userId) {
    return new ResponseEntity<>(companyService.getCompaniesAssignedToUser(userId), HttpStatus.OK);
  }

  @GetMapping(value = "/availableForUser")
  public ResponseEntity<List<Company>> getCompaniesAvailableForUser() {
    return new ResponseEntity<>(companyService.getCompaniesAvailableForUser(), HttpStatus.OK);
  }

  @GetMapping(value = "/{id}")
  public ResponseEntity<Company> getCompany(@PathVariable Long id) {
    return companyService.getCompany(id)
      .map(ResponseEntity::ok)
      .orElse(ResponseEntity.notFound().build());
  }

  @PutMapping(value = "")
  public ResponseEntity<Company> saveCompany(@RequestBody Company company) {
    return companyService.saveCompany(company)
      .map(ResponseEntity::ok)
      .orElse(ResponseEntity.notFound().build());
  }

  //configuration values
  @GetMapping(value = "/{id}/configuration")
  public ResponseEntity<List<CompanyConfigurationValue>> getCompanyConfigurationValues(@PathVariable Long id) {
    return new ResponseEntity<>(companyService.getCompanyConfigurationValues(id), HttpStatus.OK);
  }

  @PutMapping(value = "/{id}/configuration")
  public void getCompanyConfigurationValues(@RequestBody CompanyConfigurationValue ccv) {
    companyService.saveCompanyConfigurationValue(ccv);
  }

}
