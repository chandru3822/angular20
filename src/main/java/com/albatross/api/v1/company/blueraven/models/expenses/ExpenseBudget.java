package com.albatross.api.v1.company.blueraven.models.expenses;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Getter
@Setter
public class ExpenseBudget {

  private Long id;
  private String userFullName, budgetType, notes, fullBudgetName;
  private Long userId, budgetTypeId, originalExpenseBudgetId;
  private Double amount, totalExpenses, balance;
  private Date dateCreated, dateUpdated;

  @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
  private Date startDate, endDate;

}
