package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Customer  {

  private Long id, contactBaseId, companyId, customerTypeId, stateId, countryId,
      ownerUserPositionId, ownerId;
  private String firstName, lastName, fullName, email,
      street1, street2, city, state, postalCode, country,
      mailingStreet1, mailingStreet2, mailingCity, mailingState, mailingPostalCode,
      phone, mobile, customerType, ownerFirstName, ownerLastName, ownerFullName, ownerPosition;
  private Double latitude, longitude;
  // dates as strings or dates?
  private String dateCreated;

  private User owner;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}
