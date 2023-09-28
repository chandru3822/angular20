package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZonePostalCode {

  private Long id, postalCodeZoneId, postalCodeId;
  private String postalCode;
  private Boolean archived;
}
