package com.albatross.api.v1.company.blueraven.services.expenses;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.expenses.BudgetType;
import com.albatross.api.v1.company.blueraven.models.expenses.Expense;
import com.albatross.api.v1.company.blueraven.models.expenses.ExpenseBudget;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Randa Nunn
 */
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ExpenseBudgetService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;


  //budget types here
  public List<BudgetType> getBudgetTypes() {
    List<BudgetType> results = sqlCache.query("expenseBudget.budgetType.getAll", Collections.emptyMap(), BudgetType.class);
    return results;
  }

  public Optional<BudgetType> getOneBudgetType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("expenseBudget.budgetType.getOne", params, BudgetType.class);
  }

  public Optional<BudgetType> updateBudgetType(BudgetType budgetType){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("name", budgetType.getName());
    params.put("userId", currentUser.trueUserId());

    Long id;
    if(null != budgetType.getId()){
      id = budgetType.getId();
      params.put("id", budgetType.getId());
      sqlCache.update("expenseBudget.budgetType.updateBudgetType", params);
    }else{
      id = sqlCache.updateReturningId("expenseBudget.budgetType.insertBudgetType", params, "id").longValue();
    }
    return getOneBudgetType(id);
  }

  public void deleteBudgetType(Long id){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.update("expenseBudget.budgetType.deleteBudgetType", params);
  }
  //end budget types here

  public List<ExpenseBudget> getBudgets() {
    List<ExpenseBudget> results = sqlCache.query("expenseBudget.getAll", Collections.emptyMap(), ExpenseBudget.class);
    return results;
  }

  public ResponseEntity updateBudget(ExpenseBudget expenseBudget){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("budgetTypeId", expenseBudget.getBudgetTypeId());
    params.put("amount", expenseBudget.getAmount());
    params.put("startDate", expenseBudget.getStartDate());
    params.put("endDate", expenseBudget.getEndDate());
    params.put("userId", expenseBudget.getUserId());
    params.put("updatedById", expenseBudget.getUserId());
    params.put("createdById", expenseBudget.getUserId());
    params.put("notes", expenseBudget.getNotes());

    Long oldId = expenseBudget.getId();

    if(null != oldId){

      //check to see if any requests or expense line items are assigned to this budget outside of the new dates
      HashMap<String, Object> lineCheckParams = new HashMap<>();
      lineCheckParams.put("id", oldId);
      lineCheckParams.put("startDate", expenseBudget.getStartDate());
      lineCheckParams.put("endDate", expenseBudget.getEndDate());

      List<Expense> expenses = sqlCache.query("expenseBudget.checkLineItemDates", lineCheckParams, Expense.class);

      //don't edit the budget if there are line items assigned to it outside the date range
      if(expenses.isEmpty()){
        //we don't actually edit budget expenses, we add a new row to keep a history and only display the most recent one
        params.put("originalExpenseBudgetId", expenseBudget.getOriginalExpenseBudgetId());
        Long newId = sqlCache.updateReturningId("expenseBudget.insertExpenseBudget", params, "id").longValue();

        //update any expenses and reimbursement requests with the old id to the new id
        HashMap<String, Object> budgetIds = new HashMap<>();
        budgetIds.put("oldBudgetId", oldId);
        budgetIds.put("newBudgetId", newId);
        sqlCache.update("expense.updateLineItemsToNewBudgetId", budgetIds);
        sqlCache.update("reimbursement.updateLineItemsToNewBudgetId", budgetIds);
      }else{
        //return error message
        return new ResponseEntity(HttpStatus.NOT_ACCEPTABLE);
      }
    }else{
      //add the new budget with its own id as the original expense budget id if one doesn't already exist in time period
      HashMap<String, Object> templateParams = new HashMap<>();
      templateParams.put("userId", expenseBudget.getUserId());
      templateParams.put("startDate", expenseBudget.getStartDate());
      templateParams.put("endDate", expenseBudget.getEndDate());
      templateParams.put("budgetTypeId", expenseBudget.getBudgetTypeId());

      Optional<ExpenseBudget> existingExpenseBudget = sqlCache.get("expenseBudget.checkIfExistsByUserAndBudgetType", templateParams, ExpenseBudget.class);
      if(!existingExpenseBudget.isPresent()){
        Long id = sqlCache.updateReturningId("expenseBudget.insertOriginalExpenseBudget", params, "id").longValue();

        if(id > 0){
          HashMap<String, Object> updateOriginal = new HashMap<>();
          updateOriginal.put("id", id);
          sqlCache.update("expenseBudget.updateOriginalExpenseBudget", updateOriginal);
        }
      }
    }
    return null;
  }

  public List<User> getAvailableUsers() {
    List<User> results = sqlCache.query("expenseBudget.getAvailableUsers", Collections.emptyMap(), User.class);
    return results;
  }

  public List<User> getUsersWithBudget() {
    List<User> results = sqlCache.query("expenseBudget.getUsersWithBudget", Collections.emptyMap(), User.class);
    return results;
  }

  public String getAvailableBudgetsForUser(Long userId, String expenseDate) {
    String sqlQuery = "SELECT * FROM brs.get_available_budgets_for_user(:userId::integer, :expenseDate::DATE)";

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("expenseDate", expenseDate);

    String updated = sqlCache.queryForObject(sqlQuery, params, String.class);
    return updated;
  }

  public List<ExpenseBudget> getBudgetExpensesVsRemaining(Long userId, String startDate, String endDate){
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    List<ExpenseBudget> results = sqlCache.query("expenseBudget.getBudgetExpensesVsRemaining", params, ExpenseBudget.class);
    return results;
  }

  public Optional<ExpenseBudget> getBudgetRemainingById(Long budgetId){
    HashMap<String, Object> params = new HashMap<>();
    params.put("budgetId", budgetId);

    Optional<ExpenseBudget> result = sqlCache.get("expenseBudget.getBudgetRemainingById", params, ExpenseBudget.class);
    return result;
  }


  public String getMonthlyBudgetReport(Long userId, String startDate, String endDate){
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    Optional<String> result = sqlCache.get("expenseBudget.getMonthlyBudgetReport", params, new SingleColumnRowMapper<>(String.class));
    return result.orElse("{}");
  }

  public String getMonthlyBudgetReportDrilldown(Long userId, String startDate, String endDate, String status, Long budgetTypeId, Boolean individual){
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("status", status);
    params.put("budgetTypeId", budgetTypeId);
    params.put("individual", individual);

    Optional<String> result = sqlCache.get("expenseBudget.getMonthlyBudgetReportDrillDown", params, new SingleColumnRowMapper<>(String.class));
    return result.orElse("{}");
  }

}
