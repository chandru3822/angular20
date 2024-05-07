package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.Financier;
import com.albatross.api.v1.company.blueraven.services.FinancierService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/financier")
@RequiredArgsConstructor
public class FinancierController {
  private final FinancierService financierService;

  @GetMapping(value = "/active")
  public List<Financier> getAllActiveFinanciers() {
    return financierService.getAllActiveFinanciers();
  }

  @PostMapping(value = "/add")
  public Integer addFinancier(@RequestBody Financier financier) {
    return financierService.addFinancier(financier);
  }

  @PutMapping(value = "/update")
  public void updateFinancier(@RequestBody Financier financier) {
    financierService.updateFinancier(financier);
  }
}
