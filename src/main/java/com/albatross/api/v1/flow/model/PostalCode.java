package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCode {

  private Long id, roundRobinId, callGroupId, postalCodeZoneId;
  private String postalCode, placeName, notes;
  private Boolean archived, active, disqualified, selfGen, salesPartners, insideSales;
}
