package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZoneUser {

  private Long id, postalCodeZoneId, userId, postalCodeZoneUserTypeId, companyTimezoneId;
  private String firstName, lastName, fullName, position, timezone;
  private Boolean archived, schedulable, scheduler;
}
