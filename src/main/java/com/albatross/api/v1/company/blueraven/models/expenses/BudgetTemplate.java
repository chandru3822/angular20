package com.albatross.api.v1.company.blueraven.models.expenses;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Getter
@Setter
public class BudgetTemplate {

  private Long id, currentMonthBudgetId;
  private String userFullName;
  private Long userId;
  private Double amount;
  private Boolean archived;

}
