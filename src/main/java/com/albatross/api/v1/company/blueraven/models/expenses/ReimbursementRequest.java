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

  private Long id, attachmentId, glCodeId, expenseBudgetId, createdById, reimbursementRequestStatusId, expenseBudgetUserId, budgetTypeId, approvedById, submittedById;
  private String details, createdBy, userType, budgetType, expenseBudgetUser, notes, positionName, submittedBy, approvedBy, glCode;
  private Double amount;
  private Date expenseDate, dateCreated;
  private Boolean archived;

}
