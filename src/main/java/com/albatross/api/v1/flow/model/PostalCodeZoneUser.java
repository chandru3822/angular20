package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZoneUser {

  private Long id, postalCodeZoneId, userId, allocation;
  private String firstName, lastName, fullName;
  private Boolean archived;
}
