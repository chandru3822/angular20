package com.albatross.api.v1.company.blueraven.services.expenses;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.expenses.ExpenseBudgetController;
import com.albatross.api.v1.company.blueraven.models.expenses.BudgetTemplate;
import com.albatross.api.v1.company.blueraven.models.expenses.BudgetType;
import com.albatross.api.v1.company.blueraven.models.expenses.ExpenseBudget;
import com.albatross.api.v1.company.blueraven.services.expenses.queries.ExpenseBudgetQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
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

  public void deleteBudget(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.updateBySql(ExpenseBudgetQuery.delete, params);
  }

  // budget types here
  public List<BudgetType> getBudgetTypes() {
    return sqlCache.queryBySql(
        ExpenseBudgetQuery.getAllBudgetType, Collections.emptyMap(), BudgetType.class);
  }

  public Optional<BudgetType> getOneBudgetType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.getBySql(ExpenseBudgetQuery.getOneBudgetType, params, BudgetType.class);
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
      sqlCache.updateBySql(ExpenseBudgetQuery.updateBudgetType, params);
    } else {
      id =
          sqlCache
              .updateBySqlReturningId(ExpenseBudgetQuery.insertBudgetType, params, "id")
              .longValue();
    }
    return getOneBudgetType(id);
  }

  public void deleteBudgetType(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.updateBySql(ExpenseBudgetQuery.deleteBudgetType, params);
  }
  // end budget types here

  // budget templates here
  public List<BudgetTemplate> getAllBudgetTemplates() {
    return sqlCache.queryBySql(
        ExpenseBudgetQuery.getAllTemplates, Collections.emptyMap(), BudgetTemplate.class);
  }

  public void generateNextMonthBudgets() {
    sqlCache.updateBySql(ExpenseBudgetQuery.generateNextMonthBudgets, Collections.emptyMap());
  }

  public Optional<BudgetTemplate> updateBudgetTemplate(BudgetTemplate budgetTemplate) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("amount", budgetTemplate.getAmount());
    params.put("userId", currentUser.trueUserId());
    params.put("notes", "");

    Long templateId;
    if (null != budgetTemplate.getId()) {
      templateId = budgetTemplate.getId();
      params.put("id", templateId);
      sqlCache.updateBySql(ExpenseBudgetQuery.updateBudgetTemplate, params);
    } else {
      params.put("userId", budgetTemplate.getUserId());
      try {
        templateId = sqlCache.updateBySqlReturningId(ExpenseBudgetQuery.insertBudgetTemplate, params, "id").longValue();
      } catch (DuplicateKeyException e) {
        String msg = "A budget template already exists for this user";
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, msg);
      }
    }

    params.put("id", templateId);
    return sqlCache.getBySql(ExpenseBudgetQuery.getOneTemplates, params, BudgetTemplate.class);
  }

  public void deleteBudgetTemplate(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.updateBySql(ExpenseBudgetQuery.deleteBudgetTemplate, params);
  }
  // end budget templates here

  public List<ExpenseBudget> getBudgets() {
    return sqlCache.queryBySql(ExpenseBudgetQuery.getAll, Collections.emptyMap(), ExpenseBudget.class);
  }

  public void generateCurrentMonthBudgetFromTemplate(BudgetTemplate template) {
  }

  public Optional<ExpenseBudget> updateBudget(ExpenseBudget expenseBudget) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();

    params.put("amount", expenseBudget.getAmount());
    params.put("startDate", expenseBudget.getStartDate());
    params.put("endDate", expenseBudget.getEndDate());
    params.put("userId", expenseBudget.getUserId());
    params.put("updatedById", currentUser.trueUserId());
    params.put("createdById", currentUser.trueUserId());
    params.put("notes", expenseBudget.getNotes());

    Long id = expenseBudget.getId();

    if (null != id) {
      params.put("id", id);
      sqlCache.updateBySql(ExpenseBudgetQuery.updateExpenseBudget, params);
    } else {
      Optional<ExpenseBudget> existingExpenseBudget =
        sqlCache.getBySql(
          ExpenseBudgetQuery.checkIfExistsByUser,
          params,
          ExpenseBudget.class);

      if (existingExpenseBudget.isEmpty()) {
        id = sqlCache.updateBySqlReturningId(ExpenseBudgetQuery.insertExpenseBudget, params, "id").longValue();
        params.put("id", id);
      } else {
        throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "User already has a budget for the selected month.",
          new Exception());
      }
    }

    return sqlCache.getBySql(ExpenseBudgetQuery.getOne, params, ExpenseBudget.class);
  }

  public List<ExpenseBudgetController.BudgetUser> getAvailableUsers() {
    return sqlCache.queryBySql(ExpenseBudgetQuery.getAvailableUsers, Collections.emptyMap(), ExpenseBudgetController.BudgetUser.class);
  }

  public List<ExpenseBudgetController.BudgetUser> getUsersWithBudget() {
    return sqlCache.queryBySql(ExpenseBudgetQuery.getUsersWithBudget, Collections.emptyMap(), ExpenseBudgetController.BudgetUser.class);
  }

  public List<ExpenseBudget> getBudgetsForUser(Long userId) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    return sqlCache.queryBySql(ExpenseBudgetQuery.getBudgetsForUser, params, ExpenseBudget.class);
  }

  public Optional<ExpenseBudget> getBudgetRemainingById(Long budgetId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("budgetId", budgetId);

    return sqlCache.getBySql(ExpenseBudgetQuery.getBudgetRemainingById, params, ExpenseBudget.class);
  }

  public String getMonthlyBudgetReport(String startDate, String endDate) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    return sqlCache
        .getBySql(
            ExpenseBudgetQuery.getMonthlyBudgetReport,
            params,
            new SingleColumnRowMapper<>(String.class))
        .orElse("{}");
  }
}
