package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeAllocationUser {

  private Long postalCodeZoneUserId, zoneId, userId;
  private String fullName;
  private Double prescribedAllocation, targetLeadAllocation, manualAllocationWhole, manualAllocation;
}
