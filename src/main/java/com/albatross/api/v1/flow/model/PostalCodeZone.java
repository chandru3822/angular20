package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZone {

  private Long id, companyId, distributionTimeFrameDays, schedulableFutureDays;
  private String zoneName;
  private Boolean archived;
}
