package com.albatross.api.v1.company.blueraven.models.expenses;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Getter
@Setter
public class Expense {

  private Long id;
  private String glCode, createdBy, approvedBy, paidBy, budgetType, notes,
    submittedBy, expenseBudgetUser, positionName, reimbursementRequestDetails;
  private Double expenseAmount;
  private Long expenseBudgetId, createdById, approvedById, paidByUserId, reimbursementRequestId,
    userId, paidById, glCodeId, submittedById, expenseBudgetUserId, updatedByUserId, rejectedByUserId, positionId;
  private Date dateCreated, approvalDate, paidDate, expenseDate, dateSubmitted, rejectedDate;
  private Boolean skipApproval, archived;

}
