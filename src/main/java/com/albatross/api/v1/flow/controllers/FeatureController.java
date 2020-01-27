package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyFeature;
import com.albatross.api.v1.flow.services.FeatureService;
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
@RequestMapping(value = "/api/v1/flow/feature")
public class FeatureController {

  @Autowired
  private FeatureService featureService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFeature> getFeaturesForCompany() {
    return featureService.getFeaturesForCompany();
  }

  @GetMapping(value = "/withAccess", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFeature> getFeaturesForCompanyWithAccess() {
    return featureService.getFeaturesForCompanyWithAccess();
  }

  @GetMapping(value = "/user/{userId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFeature> getFeaturesForUser(@PathVariable Long userId) {
    return featureService.getFeaturesForUser(userId);
  }

  @PutMapping(value = "/user/{userId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveCompanyFeatures(@PathVariable Long userId, @RequestBody List<CompanyFeature> companyFeatures) {
    featureService.saveCompanyFeatures(userId, companyFeatures);
  }

}
