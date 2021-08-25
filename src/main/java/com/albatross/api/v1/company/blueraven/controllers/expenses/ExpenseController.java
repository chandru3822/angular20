package com.albatross.api.v1.company.blueraven.controllers.expenses;

import com.albatross.api.v1.company.blueraven.models.expenses.GlCode;
import com.albatross.api.v1.company.blueraven.services.expenses.ExpenseService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/expenses")
public class ExpenseController {

  private final ExpenseService expenseService;

  @GetMapping(value = "/glCodes")
  public List<GlCode> getAllGlCodes() {
    return expenseService.getAllGlCodes();
  }

  @PostMapping(value = "/glCode", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<GlCode> saveGlCode(@RequestBody GlCode glCode) {
    return expenseService.saveGlCode(glCode);
  }

  @DeleteMapping(value = "/glCode/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteGlCode(@PathVariable Long id) {
    expenseService.deleteGlCode(id);
  }

}
