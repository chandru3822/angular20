package com.albatross.api.v1.company.blueraven.services.expenses;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.expenses.BudgetTemplate;
import com.albatross.api.v1.company.blueraven.models.expenses.BudgetType;
import com.albatross.api.v1.company.blueraven.models.expenses.Expense;
import com.albatross.api.v1.company.blueraven.models.expenses.ExpenseBudget;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Service
@RequiredArgsConstructor
public class ExpenseBudgetService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  // budget types here
  public List<BudgetType> getBudgetTypes() {
    return sqlCache.query(
        "expenseBudget.budgetType.getAll", Collections.emptyMap(), BudgetType.class);
  }

  public Optional<BudgetType> getOneBudgetType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("expenseBudget.budgetType.getOne", params, BudgetType.class);
  }

  public Optional<BudgetType> updateBudgetType(BudgetType budgetType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("name", budgetType.getName());
    params.put("userId", currentUser.trueUserId());

    Long id;
    if (null != budgetType.getId()) {
      id = budgetType.getId();
      params.put("id", budgetType.getId());
      sqlCache.update("expenseBudget.budgetType.updateBudgetType", params);
    } else {
      id =
          sqlCache
              .updateReturningId("expenseBudget.budgetType.insertBudgetType", params, "id")
              .longValue();
    }
    return getOneBudgetType(id);
  }

  public void deleteBudgetType(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.update("expenseBudget.budgetType.deleteBudgetType", params);
  }
  // end budget types here

  // budget templates here
  public List<BudgetTemplate> getAllBudgetTemplates() {
    return sqlCache.query(
        "expenseBudget.templates.getAll", Collections.emptyMap(), BudgetTemplate.class);
  }

  public Optional<BudgetTemplate> updateBudgetTemplate(BudgetTemplate budgetTemplate) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("budgetTypeId", budgetTemplate.getBudgetTypeId());
    params.put("userId", budgetTemplate.getUserId());
    params.put("amount", budgetTemplate.getAmount());
    params.put("updatedById", currentUser.trueUserId());
    params.put("notes", "");

    Long templateId;
    if (null != budgetTemplate.getId()) {
      templateId = budgetTemplate.getId();
      params.put("id", budgetTemplate.getId());
      sqlCache.update("expenseBudget.templates.updateBudgetTemplate", params);
    } else {
      params.put("createdById", currentUser.trueUserId());
      Long id =
          sqlCache
              .updateReturningId("expenseBudget.templates.insertBudgetTemplate", params, "id")
              .longValue();
      templateId = id;

      Date today = new Date();
      Calendar calendar = Calendar.getInstance();
      calendar.setTime(today);
      calendar.set(Calendar.DAY_OF_MONTH, 1);
      Date firstDayOfMonth = calendar.getTime();
      calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH));
      Date lastDayOfMonth = calendar.getTime();

      HashMap<String, Object> templateParams = new HashMap<>();
      templateParams.put("id", id);
      templateParams.put("startDate", firstDayOfMonth);
      templateParams.put("endDate", lastDayOfMonth);

      // creates an expense budget if a budget does not already exist for this user, budget type,
      // and month
      Optional<ExpenseBudget> expenseBudget =
          sqlCache.get(
              "expenseBudget.checkIfExistsByTemplate", templateParams, ExpenseBudget.class);

      if (expenseBudget.isEmpty()) {

        params.put("startDate", firstDayOfMonth);
        params.put("endDate", lastDayOfMonth);

        long newId =
            sqlCache
                .updateReturningId("expenseBudget.insertOriginalExpenseBudget", params, "id")
                .longValue();

        if (newId > 0) {
          HashMap<String, Object> updateOriginal = new HashMap<>();
          updateOriginal.put("id", newId);
          sqlCache.update("expenseBudget.updateOriginalExpenseBudget", updateOriginal);
        }
        //                sqlCache.update("expenseBudget.insertExpenseBudget", params);
      }
    }

    HashMap<String, Object> tParams = new HashMap<>();
    tParams.put("id", templateId);
    return sqlCache.get("expenseBudget.templates.getOne", tParams, BudgetTemplate.class);
  }

  public void deleteBudgetTemplate(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.update("expenseBudget.template.deleteBudgetTemplate", params);
  }
  // end budget templates here

  public List<ExpenseBudget> getBudgets() {
    return sqlCache.query("expenseBudget.getAll", Collections.emptyMap(), ExpenseBudget.class);
  }

  public Optional<ExpenseBudget> updateBudget(ExpenseBudget expenseBudget) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("budgetTypeId", expenseBudget.getBudgetTypeId());
    params.put("amount", expenseBudget.getAmount());
    params.put("startDate", expenseBudget.getStartDate());
    params.put("endDate", expenseBudget.getEndDate());
    params.put("userId", expenseBudget.getUserId());
    params.put("updatedById", expenseBudget.getUserId());
    params.put("createdById", expenseBudget.getUserId());
    params.put("notes", expenseBudget.getNotes());

    Long budgetIdToReturn = null;
    Long oldId = expenseBudget.getId();

    if (null != oldId) {

      // check to see if any requests or expense line items are assigned to this budget outside of
      // the new dates
      HashMap<String, Object> lineCheckParams = new HashMap<>();
      lineCheckParams.put("id", oldId);
      lineCheckParams.put("startDate", expenseBudget.getStartDate());
      lineCheckParams.put("endDate", expenseBudget.getEndDate());

      List<Expense> expenses =
          sqlCache.query("expenseBudget.checkLineItemDates", lineCheckParams, Expense.class);

      // don't edit the budget if there are line items assigned to it outside the date range
      if (expenses.isEmpty()) {
        // we don't actually edit budget expenses, we add a new row to keep a history and only
        // display the most recent one
        params.put("originalExpenseBudgetId", expenseBudget.getOriginalExpenseBudgetId());
        Long newId =
            sqlCache
                .updateReturningId("expenseBudget.insertExpenseBudget", params, "id")
                .longValue();
        budgetIdToReturn = newId;

        // update any expenses and reimbursement requests with the old id to the new id
        HashMap<String, Object> budgetIds = new HashMap<>();
        budgetIds.put("oldBudgetId", oldId);
        budgetIds.put("newBudgetId", newId);
        sqlCache.update("expense.updateLineItemsToNewBudgetId", budgetIds);
        sqlCache.update("reimbursement.updateLineItemsToNewBudgetId", budgetIds);
      } else {
        // return error message
        throw new ResponseStatusException(HttpStatus.NOT_ACCEPTABLE, "", new Exception());
        //        return new ResponseEntity(HttpStatus.NOT_ACCEPTABLE);
      }
    } else {
      // add the new budget with its own id as the original expense budget id if one doesn't already
      // exist in time period
      HashMap<String, Object> templateParams = new HashMap<>();
      templateParams.put("userId", expenseBudget.getUserId());
      templateParams.put("startDate", expenseBudget.getStartDate());
      templateParams.put("endDate", expenseBudget.getEndDate());
      templateParams.put("budgetTypeId", expenseBudget.getBudgetTypeId());

      Optional<ExpenseBudget> existingExpenseBudget =
          sqlCache.get(
              "expenseBudget.checkIfExistsByUserAndBudgetType",
              templateParams,
              ExpenseBudget.class);
      if (existingExpenseBudget.isEmpty()) {
        long id =
            sqlCache
                .updateReturningId("expenseBudget.insertOriginalExpenseBudget", params, "id")
                .longValue();
        budgetIdToReturn = id;
        if (id > 0) {
          HashMap<String, Object> updateOriginal = new HashMap<>();
          updateOriginal.put("id", id);
          sqlCache.update("expenseBudget.updateOriginalExpenseBudget", updateOriginal);
        }
      } else {
        throw new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "User already has a budget that overlaps the selected days.",
            new Exception());
      }
    }
    HashMap<String, Object> ebParams = new HashMap<>();
    ebParams.put("id", budgetIdToReturn);
    return sqlCache.get("expenseBudget.getOne", ebParams, ExpenseBudget.class);
  }

  public List<User> getAvailableUsers() {
    return sqlCache.query("expenseBudget.getAvailableUsers", Collections.emptyMap(), User.class);
  }

  public List<User> getUsersWithBudget() {
    return sqlCache.query("expenseBudget.getUsersWithBudget", Collections.emptyMap(), User.class);
  }

  public String getAvailableBudgetsForUser(Long userId, String expenseDate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("expenseDate", expenseDate);

    String updated =
        sqlCache.queryForObject("expenseBudget.getAvailableBudgetsForUser", params, String.class);
    return null != updated ? updated : "[]";
  }

  public List<ExpenseBudget> getBudgetExpensesVsRemaining(
      Long userId, String startDate, String endDate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    return sqlCache.query(
        "expenseBudget.getBudgetExpensesVsRemaining", params, ExpenseBudget.class);
  }

  public Optional<ExpenseBudget> getBudgetRemainingById(Long budgetId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("budgetId", budgetId);

    return sqlCache.get("expenseBudget.getBudgetRemainingById", params, ExpenseBudget.class);
  }

  public String getMonthlyBudgetReport(String startDate, String endDate) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    return sqlCache
        .get(
            "expenseBudget.getMonthlyBudgetReport",
            params,
            new SingleColumnRowMapper<>(String.class))
        .orElse("{}");
  }

  public String getMonthlyBudgetReportDrilldown(
      Long userId,
      String startDate,
      String endDate,
      String status,
      Long budgetTypeId,
      Boolean individual) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("status", status);
    params.put("budgetTypeId", budgetTypeId);
    params.put("individual", individual);

    return sqlCache
        .get(
            "expenseBudget.getMonthlyBudgetReportDrillDown",
            params,
            new SingleColumnRowMapper<>(String.class))
        .orElse("{}");
  }
}
