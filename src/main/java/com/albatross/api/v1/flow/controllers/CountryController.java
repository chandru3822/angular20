package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyCountry;
import com.albatross.api.v1.flow.services.CountryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/country")
@RequiredArgsConstructor
public class CountryController {

  private final CountryService countryService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyCountry> getAllCountries() {
    return countryService.getAllCountries();
  }

  @GetMapping(value = "/company", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyCountry> getAllCountriesForCompany(@RequestParam(required = false) Long companyId) {
    return countryService.getAllCountriesForCompany(companyId);
  }
}
