package com.albatross.api.v1.company.blueraven.services.expenses;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.expenses.Expense;
import com.albatross.api.v1.company.blueraven.models.expenses.GlCode;
import com.albatross.api.v1.company.blueraven.models.expenses.ReimbursementRequest;
import com.albatross.api.v1.company.blueraven.services.expenses.queries.ExpenseQuery;
import com.albatross.api.v1.company.blueraven.services.expenses.queries.ReimbursementQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * Created by Randa Nunn
 */
@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ExpenseService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ReimbursementService reimbursementService;

  public List<GlCode> getAllGlCodes() {
    return sqlCache.queryBySql(ExpenseQuery.getAllGlCodes, Collections.emptyMap(), GlCode.class);
  }

  public Optional<GlCode> getOneGlCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.getBySql(ExpenseQuery.getOneGlCode, params, GlCode.class);
  }

  public Optional<GlCode> saveGlCode(GlCode glCode){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("code", glCode.getCode());
    params.put("description", glCode.getDescription());
    params.put("userId", currentUser.trueUserId());

    Long id;
    if(null != glCode.getId()){
      id = glCode.getId();
      params.put("id", glCode.getId());
      sqlCache.updateBySql(ExpenseQuery.updateGlCode, params);
    }else{
      id = sqlCache.updateBySqlReturningId(ExpenseQuery.insertGlCode, params, "id").longValue();
    }

    return getOneGlCode(id);
  }

  public void deleteGlCode(Long id){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.updateBySql(ExpenseQuery.deleteGlCode, params);
  }


  //expense stuff
  public void addExpenseItems(List<Expense> expenses) {
    User currentUser = securityService.getCurrentUser();

    for (Expense expense : expenses) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("expenseBudgetId", expense.getExpenseBudgetId());
      params.put("expenseDate", expense.getExpenseDate());
      params.put("submittedById", currentUser.trueUserId());
      params.put("glCodeId", expense.getGlCodeId());
      params.put("notes", expense.getNotes());
      params.put("reimbursementRequestId", expense.getReimbursementRequestId());
      //this is the user id of the purchaser
      params.put("userId", expense.getUserId());
      params.put("expenseAmount", expense.getExpenseAmount());
      //not sure what this is yet
      params.put("skipApproval", null != expense.getSkipApproval() ? expense.getSkipApproval() : false);

      if (null != expense.getId()) {
        params.put("id", expense.getId());
        params.put("updatedByUserId", expense.getUpdatedByUserId());
        sqlCache.updateBySql(ExpenseQuery.updateDefaultExpense, params);
      } else {
        sqlCache.updateBySql(ExpenseQuery.insertExpense, params);
      }
    }
  }


  public void addDefaultLineItem(Expense expense) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("expenseDate", expense.getExpenseDate());
    params.put("reimbursementRequestId", expense.getReimbursementRequestId());
    params.put("userId", currentUser.getId());
    params.put("expenseAmount", expense.getExpenseAmount());
    params.put("expenseBudgetId", expense.getExpenseBudgetId());

    sqlCache.updateBySql(ExpenseQuery.addDefaultLineItem, params);
  }

  public List<Expense> getAllInDateRange(Date startDate, Date endDate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    List<Expense> results = sqlCache.queryBySql(ExpenseQuery.getAllInDateRange, params, Expense.class);
    return results;
  }

  public List<Expense> getAllUnpaidExpenses() {
    List<Expense> results = sqlCache.queryBySql(ExpenseQuery.getAllUnpaid, Collections.emptyMap(), Expense.class);
    return results;
  }

  public List<Expense> getAllPaidExpenses(Date startDate, Date endDate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    List<Expense> results = sqlCache.queryBySql(ExpenseQuery.getAllPaidInDateRange, params, Expense.class);
    return results;
  }

  public void payExpenses(List<Expense> expenses) {
    User currentUser = securityService.getCurrentUser();

    for (Expense e : expenses) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("id", e.getId());
      params.put("paidById", currentUser.trueUserId());
      sqlCache.updateBySql(ExpenseQuery.payExpense, params);

      if (null != e.getReimbursementRequestId()) {
        //see if there are any other expense line items for that request
        params.put("requestId", e.getReimbursementRequestId());
        List<Expense> unpaid = sqlCache.queryBySql(ExpenseQuery.getUnpaidExpensesForRequest, params, Expense.class);

        //if not, mark the request as approved by the same user
        if (unpaid.isEmpty()) {
          ReimbursementRequest rr = new ReimbursementRequest();
          rr.setId(e.getReimbursementRequestId());
          rr.setReimbursementRequestStatusId(1L);
          reimbursementService.updateRequestStatus(rr);
        }
      }
    }
  }

  public void approveExpenses(List<Expense> expenses) {
    User currentUser = securityService.getCurrentUser();

    for (Expense e : expenses) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("id", e.getId());
      params.put("approvedById", currentUser.trueUserId());
      params.put("reviewedById", null == e.getSubmittedById() ? currentUser.trueUserId() : e.getSubmittedById());
      params.put("dateReviewed", e.getDateSubmitted());
      sqlCache.updateBySql(ExpenseQuery.approveExpense, params);

    }
  }

  public void rejectExpenses(List<Expense> expenses) {
    User currentUser = securityService.getCurrentUser();

    for (Expense expense : expenses) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("id", expense.getId());
      //dont ask why i have 2 of the same, i just dont want to figure it out either
      params.put("userId", currentUser.trueUserId());
      params.put("rejectedById", currentUser.trueUserId());

      if (null != expense.getReimbursementRequestId()) {
        //if one line item is rejected then the rest in that request have to be rejected as well
        params.put("requestId", expense.getReimbursementRequestId());
        sqlCache.updateBySql(ExpenseQuery.rejectAllExpensesForRequest, params);

        //then reject the actual request
        HashMap<String, Object> params2 = new HashMap<>();
        params2.put("id", expense.getReimbursementRequestId());
        params2.put("reimbursementRequestStatusId", 2);
        sqlCache.updateBySql(ReimbursementQuery.updateStatus, params2);

        if (null != expense.getNotes()) {
          params2.put("notes", expense.getNotes());
          sqlCache.updateBySql(ReimbursementQuery.saveReimbursementNote, params2);
        }
      } else {
        //reject the line item
        sqlCache.updateBySql(ExpenseQuery.rejectExpense, params);
      }


    }
  }

  public void editExpenseLineItem(Expense expense) {
    Long submittedById = expense.getSubmittedById();

    if (null != expense.getGlCodeId()) {
      //if they set a GL Code save submitted by as the current user
      submittedById = expense.getUpdatedByUserId();
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("glCodeId", expense.getGlCodeId());
    params.put("id", expense.getId());
    params.put("expenseBudgetId", expense.getExpenseBudgetId());
    params.put("updatedByUserId", expense.getUpdatedByUserId());
    params.put("expenseDate", expense.getExpenseDate());
    params.put("expenseAmount", expense.getExpenseAmount());
    params.put("paidDate", expense.getPaidDate());
    params.put("notes", expense.getNotes());
    params.put("paidById", null == expense.getPaidDate() ? null : expense.getPaidById());
    params.put("submittedById", submittedById);

    sqlCache.updateBySql(ExpenseQuery.updateExpense, params);
  }

  public void deleteExpense(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.updateBySql(ExpenseQuery.deleteExpense, params);
  }

}
