package com.albatross.api.v1.company.blueraven.controllers.expenses;

import com.albatross.api.v1.company.blueraven.models.expenses.Expense;
import com.albatross.api.v1.company.blueraven.models.expenses.GlCode;
import com.albatross.api.v1.company.blueraven.models.expenses.ReimbursementRequest;
import com.albatross.api.v1.company.blueraven.services.expenses.ExpenseService;
import com.albatross.api.v1.company.blueraven.services.expenses.ReimbursementService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.time.ZonedDateTime;
import java.util.Date;
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
  private final ReimbursementService reimbursementService;

  //gl code stuff
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

  //expense stuff
  @PostMapping(value = "/addExpenseItems", produces = MediaType.APPLICATION_JSON_VALUE)
  public void addExpenseItems(@RequestBody List<Expense> expenses) {
    //save the expense line items
    expenseService.addExpenseItems(expenses);

    //then update the request status to approved if this was done through the reimbursement approval screen
    if(null != expenses.get(0).getReimbursementRequestId()){
      ReimbursementRequest request = new ReimbursementRequest();
      request.setId(expenses.get(0).getReimbursementRequestId());
      request.setReimbursementRequestStatusId(1L);
      reimbursementService.updateRequestStatus(request);
    }
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public void editExpenseLineItem(@RequestBody Expense expense) {
    expenseService.editExpenseLineItem(expense);
  }

  @GetMapping(value = "/list", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Expense> getAllInDateRange(@RequestParam Date startDate,
                                         @RequestParam Date endDate) {
    return expenseService.getAllInDateRange(startDate, endDate);
  }

  @GetMapping(value = "/unpaid", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Expense> getAllUnpaidExpenses() {
    return expenseService.getAllUnpaidExpenses();
  }

  @GetMapping(value = "/paid", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Expense> getAllPaidExpenses(@RequestParam Date startDate,
                                          @RequestParam Date endDate) {
    return expenseService.getAllPaidExpenses(startDate, endDate);
  }

  @PostMapping(value = "/markExpensesPaid", produces = MediaType.APPLICATION_JSON_VALUE)
  public void payExpenses(@RequestBody List<Expense> expenses) {
    expenseService.payExpenses(expenses);
  }

  @PostMapping(value = "/markExpensesApproved", produces = MediaType.APPLICATION_JSON_VALUE)
  public void approveExpenses(@RequestBody List<Expense> expenses) {
    expenseService.approveExpenses(expenses);
  }

  @PostMapping(value = "/markExpensesRejected", produces = MediaType.APPLICATION_JSON_VALUE)
  public void rejectExpenses(@RequestBody List<Expense> expenses) {
    expenseService.rejectExpenses(expenses);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteExpense(@PathVariable("id") Long id) {
    expenseService.deleteExpense(id);
  }

  @PostMapping(value = "/populate-next-months-budgets", produces = MediaType.APPLICATION_JSON_VALUE)
  public void populateNextMonthsBudgets(
    @RequestParam(required = false) String date
  ) {
    ZonedDateTime theDate = null;
    if (date != null) {
      theDate = ZonedDateTime.parse(date);
    }

    expenseService.populateNextMonthsBudgets(theDate);
  }

}
