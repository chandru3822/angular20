package com.albatross.api.v1.company.blueraven.models.expenses;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Getter
@Setter
public class ReimbursementRequest {

  private Long id, attachmentId, glCodeId, expenseBudgetId, createdById, reimbursementRequestStatusId, expenseBudgetUserId, budgetTypeId, approvedById, submittedById, paidById;
  private String details, createdBy, userType, budgetType, expenseBudgetUser, notes, positionName, submittedBy, approvedBy, glCode, paidBy;
  private Double amount;
  private Date expenseDate, dateCreated, dateSubmitted, approvalDate, paidDate;
  private Boolean archived;

}
