package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj;

import com.albatross.api.v1.company.blueraven.models.featDB.AhjSummary;
import com.albatross.api.v1.company.blueraven.services.featDB.AhjService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PostAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/featDb/ahj")
public class AhjController {
  private final AhjService ahjService;

  @GetMapping(value = "")
  public List<AhjSummary> getAhjList() {
    return ahjService.getAhjList();
  }

  @PostAuthorize("returnObject.get().getArchived() == true && hasFeatureAccessLevel('AHJ_ADMIN') || returnObject.get().getArchived() == false")
  @GetMapping(value = "/{id}")
  public Optional<AhjSummary> getAhjById(@PathVariable Long id) {
    return ahjService.getAhjById(id);
  }

  @PostMapping(value = "")
  public Optional<AhjSummary> createAhj(@RequestBody AhjSummary ahjSummary) {
    return ahjService.saveAhj(null, ahjSummary);
  }

  @PutMapping(value = "/simpleUpdate")
  public Optional<AhjSummary> simpleUpdate(@RequestBody AhjSummary ahj) {
    return ahjService.simpleUpdate(ahj);
  }

  @PutMapping(value = "/{id}")
  public Optional<AhjSummary> updateAhj(@PathVariable Long id, @RequestBody AhjSummary ahj) {
    return ahjService.saveAhj(id, ahj);
  }

  @DeleteMapping(value = "/{id}/archive")
  public void deleteAhj(@PathVariable Long id) {
    ahjService.deleteAhj(id);
  }

  @PostMapping(value = "/{id}/restore")
  public Optional<AhjSummary> restoreAhj(@PathVariable Long id) {
    return ahjService.restoreAhj(id);
  }

}
