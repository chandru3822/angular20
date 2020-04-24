package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class WorkDay {

  private Long id, companyWeekStartDayOfWeekId;
  private String dayOfWeek, abbreviation;
}
