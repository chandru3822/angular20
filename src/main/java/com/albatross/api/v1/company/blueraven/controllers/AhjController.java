package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.AhjSummary;
import com.albatross.api.v1.company.blueraven.services.AhjService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/ahj")
public class AhjController {
  @Autowired
  private AhjService ahjService;

  @RequestMapping(value = "", method = RequestMethod.GET)
  public List<AhjSummary> getAhjList() {
    return ahjService.getAhjList();
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.GET)
  public Optional<AhjSummary> getAhjById(@PathVariable Long id) {
    return ahjService.getAhjById(id);
  }

  @RequestMapping(value = "", method = RequestMethod.POST)
  public Optional<AhjSummary> createAhj(@RequestBody AhjSummary ahjSummary) {
    return ahjService.createAhj(ahjSummary);
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.PUT)
  public Optional<AhjSummary> updateAhj(@PathVariable Long id, @RequestBody AhjSummary ahj) {
    return ahjService.saveAhj(id, ahj);
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.DELETE)
  public void deleteAhj(@PathVariable Long id) {
    ahjService.deleteAhj(id);
  }

  @RequestMapping(value = "/getInspectionTypeFields", method = RequestMethod.GET)
  public String getInspectionTypeFields() {
    return ahjService.getInspectionTypeFields();
  }
}