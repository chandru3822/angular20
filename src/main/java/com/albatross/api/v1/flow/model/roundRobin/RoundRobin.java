package com.albatross.api.v1.flow.model.roundRobin;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class RoundRobin {

  private Long id, companyId, distributionTimeFrameDays, schedulableFutureDays, companyTimezoneId;
  private String roundRobinName, timezone;
  private Boolean archived, remote;
}
