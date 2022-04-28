package com.albatross.api.v1.flow.model.postalCode;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZone {

  private Long id, companyId, distributionTimeFrameDays, schedulableFutureDays, companyTimezoneId;
  private String zoneName, timezone;
  private Boolean archived, remote;
}
