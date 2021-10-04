package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Contact {

  private Long id, contactBaseId, companyId, contactTypeId, companyStateId, companyCountryId;
  private String firstName, lastName, fullName, email,
      street1, street2, city, state, postalCode, country, countryId,
      mailingStreet1, mailingStreet2, mailingCity, mailingState, mailingPostalCode,
      phone, mobile, contactType, companyName;
  private Date dateCreated;
  private Boolean ownerReadOnly;
  private Double latitude, longitude;

  //tells server to update geolocation
  private Boolean reloadCoordinates = false;

  private Owner owner;

  private List<Project> projects;
  private List<WhiteListedPosition> ownerReadOnlyWhiteListedPositions;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}
