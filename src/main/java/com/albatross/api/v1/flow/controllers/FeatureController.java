package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyFeature;
import com.albatross.api.v1.flow.model.Feature;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
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
  public List<Feature> getAllFeatures() {
    return featureService.getAllFeatures();
  }

  @GetMapping(value = "/companyTools", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Feature> getCompanySpecificTools() {
      return featureService.getCompanySpecificTools();
  }
  
  @GetMapping(value = "/access/allUserPositions", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<FeatureAccessControl> getPositionAccessForUser(@RequestParam Long userId) {
      return featureService.getPositionAccessForUser(userId);
  }

  @GetMapping(value = "/homePages", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Feature> getHomePagesForCompany() {
    return featureService.getHomePagesForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteFeature(@PathVariable Long id) {
    featureService.deleteFeature(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Feature saveFeature(@RequestBody Feature feature) {
    return featureService.saveFeature(feature);
  }

  @GetMapping(value = "/company", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFeature> getFeaturesForCompany() {
    return featureService.getFeaturesForCompany();
  }

  @PutMapping(value = "/company", produces = MediaType.APPLICATION_JSON_VALUE)
  public CompanyFeature saveCompanyFeature(@RequestBody CompanyFeature feature) {
    return featureService.saveCompanyFeature(feature);
  }

  @DeleteMapping(value = "/company/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCompanyFeature(@PathVariable Long id) {
    featureService.deleteCompanyFeature(id);
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
  public List<CompanyFeature> saveUserCompanyFeatures(@PathVariable Long userId, @RequestBody List<CompanyFeature> companyFeatures) {
    return featureService.saveUserCompanyFeatures(userId, companyFeatures);
  }

}
