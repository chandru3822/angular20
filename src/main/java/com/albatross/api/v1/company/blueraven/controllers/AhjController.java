package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.ahj.AhjSummary;
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

  @GetMapping(value = "")
  public List<AhjSummary> getAhjList() {
    return ahjService.getAhjList();
  }

  @GetMapping(value = "/{id}")
  public Optional<AhjSummary> getAhjById(@PathVariable Long id) {
    return ahjService.getAhjById(id);
  }

  @PostMapping(value = "")
  public Optional<AhjSummary> createAhj(@RequestBody AhjSummary ahjSummary) {
    return ahjService.createAhj(ahjSummary);
  }

  @PutMapping(value = "/{id}")
  public Optional<AhjSummary> updateAhj(@PathVariable Long id, @RequestBody AhjSummary ahj) {
    return ahjService.saveAhj(id, ahj);
  }

  @DeleteMapping(value = "/{id}")
  public void deleteAhj(@PathVariable Long id) {
    ahjService.deleteAhj(id);
  }

}
