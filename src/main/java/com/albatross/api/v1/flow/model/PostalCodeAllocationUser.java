package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeAllocationUser {

  private Long postalCodeZoneUserId, zoneId, userId, companyTimezoneId;
  private String fullName, timezone;
  private Double prescribedAllocation, targetLeadAllocation, manualAllocationWhole, manualAllocation;
  private Boolean edit = false;
}
