package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class CallGroup {

  private Long id, companyId;
  private String callGroupName;
  private Integer postalCodesCount, activePhoneNumbersCount, maxCallCount, daysPerPeriod;
  private Boolean active, archived, maxCallCountHit;
}
