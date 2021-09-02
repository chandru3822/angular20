package com.albatross.api.v1.company.blueraven.controllers.expenses;

import com.albatross.api.v1.company.blueraven.models.expenses.BudgetTemplate;
import com.albatross.api.v1.company.blueraven.models.expenses.BudgetType;
import com.albatross.api.v1.company.blueraven.models.expenses.ExpenseBudget;
import com.albatross.api.v1.company.blueraven.services.expenses.ExpenseBudgetService;
import com.albatross.api.v1.flow.model.User;
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
@RequestMapping(value = "/api/v1/company/blueraven/expenseBudgets")
public class ExpenseBudgetController {

  private final ExpenseBudgetService expenseBudgetService;

  //budget types here
  @GetMapping(value = "/budgetTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<BudgetType> getBudgetTypes() {
    return expenseBudgetService.getBudgetTypes();
  }

  @PostMapping(value = "/budgetType", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<BudgetType> updateBudgetType(@RequestBody BudgetType budgetType) {
    return expenseBudgetService.updateBudgetType(budgetType);
  }

  @DeleteMapping(value = "/budgetType/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteBudgetType(@PathVariable Long id) {
    expenseBudgetService.deleteBudgetType(id);
  }
  //end budget types here
  //budget templates here
  @GetMapping(value = "/templates", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<BudgetTemplate> getBudgetTemplates() {
    return expenseBudgetService.getAllBudgetTemplates();
  }

  @PostMapping(value = "/templates", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<BudgetTemplate> updateBudgetTemplate(@RequestBody BudgetTemplate budgetTemplate){
    return expenseBudgetService.updateBudgetTemplate(budgetTemplate);
  }

  @DeleteMapping(value = "/templates/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteBudgetTemplate(@PathVariable Long id){
    expenseBudgetService.deleteBudgetTemplate(id);
  }
  //end budget templates here

  @GetMapping(value = "/list",  produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ExpenseBudget> getBudgets() {
    return expenseBudgetService.getBudgets();
  }

  @GetMapping(value = "/availableForUser",  produces = MediaType.APPLICATION_JSON_VALUE)
  public String getAvailableBudgetsForUser(@RequestParam Long userId,
                                           @RequestParam String expenseDate) {
    return expenseBudgetService.getAvailableBudgetsForUser(userId, expenseDate);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ExpenseBudget> updateBudget(@RequestBody ExpenseBudget expenseBudget) {
    return expenseBudgetService.updateBudget(expenseBudget);
  }

  @GetMapping(value = "/availableUsers",  produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getAvailableUsers() {
    return expenseBudgetService.getAvailableUsers();
  }

  @GetMapping(value = "/usersWithBudget",  produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getUsersWithBudget() {
    return expenseBudgetService.getUsersWithBudget();
  }

  @GetMapping(value = "/userBudgetDetails/{id}",  produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ExpenseBudget> getBudgetExpensesVsRemaining(@PathVariable("id") Long userId,
                                                          @RequestParam String startDate,
                                                          @RequestParam String endDate) {
    return expenseBudgetService.getBudgetExpensesVsRemaining(userId, startDate, endDate);
  }

  @GetMapping(value = "/getMonthlyBudgetReport",  produces = MediaType.APPLICATION_JSON_VALUE)
  public String getMonthlyBudgetReport(@RequestParam String startDate,
                                       @RequestParam String endDate) {
    return expenseBudgetService.getMonthlyBudgetReport(startDate, endDate);
  }

  @GetMapping(value = "/getMonthlyBudgetReportDrilldown/{userId}",  produces = MediaType.APPLICATION_JSON_VALUE)
  public String getMonthlyBudgetReportDrilldown(@PathVariable("userId") Long userId,
                                                @RequestParam String startDate,
                                                @RequestParam String endDate,
                                                @RequestParam String status,
                                                @RequestParam Long budgetTypeId,
                                                @RequestParam Boolean individual) {
    return expenseBudgetService.getMonthlyBudgetReportDrilldown(userId, startDate, endDate, status, budgetTypeId, individual);
  }

  @GetMapping(value = "/budgetRemaining/{id}",  produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ExpenseBudget> getBudgetRemainingById(@PathVariable("id") Long budgetId) {
    return expenseBudgetService.getBudgetRemainingById(budgetId);
  }

}
