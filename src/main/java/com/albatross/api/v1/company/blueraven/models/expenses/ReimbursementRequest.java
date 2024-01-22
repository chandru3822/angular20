package com.albatross.api.v1.company.blueraven.models.expenses;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Getter
@Setter
public class ReimbursementRequest {

  private Long id, attachmentId, glCodeId, expenseBudgetId, createdById, reimbursementRequestStatusId, expenseBudgetUserId, budgetTypeId;
  private String details, createdBy, userType, budgetType, expenseBudgetUser, notes, positionName;
  private Double amount;
  private Date expenseDate, dateCreated;
  private List<Expense> expenses;
  private Boolean archived;

}
