package com.albatross.api.v1.flow.model.roundRobin;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class RoundRobinAllocationUser {

  private Long roundRobinUserId, roundRobinId, userId, companyTimezoneId;
  private String fullName, timezone;
  private Double prescribedAllocation, targetLeadAllocation, manualAllocationWhole, manualAllocation;
  private Boolean edit = false;
}
