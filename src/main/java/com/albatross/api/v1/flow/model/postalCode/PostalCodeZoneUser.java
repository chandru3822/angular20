package com.albatross.api.v1.flow.model.postalCode;

import com.albatross.api.v1.flow.model.UserPosition;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZoneUser {

  private Long id, postalCodeZoneId, userId, postalCodeZoneUserTypeId, companyTimezoneId;
  private String firstName, lastName, fullName, position, timezone, title, zoneName;
  private Boolean archived, schedulable, scheduler;
  private List<UserPosition> userPositions;
}
