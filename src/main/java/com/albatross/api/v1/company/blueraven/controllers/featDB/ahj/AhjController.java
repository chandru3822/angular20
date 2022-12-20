package com.albatross.api.v1.company.blueraven.controllers.featDB.ahj;

import com.albatross.api.v1.company.blueraven.models.featDB.AhjSummary;
import com.albatross.api.v1.company.blueraven.services.featDB.AhjService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
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

  @GetMapping(value = "/{id}")
  public Optional<AhjSummary> getAhjById(@PathVariable Long id) {
    return ahjService.getAhjById(id);
  }

  @PostMapping(value = "")
  public Optional<AhjSummary> createAhj(@RequestBody AhjSummary ahjSummary) {
    return ahjService.saveAhj(null, ahjSummary);
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
