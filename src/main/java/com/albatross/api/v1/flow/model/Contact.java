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
      street1, street2, city, state, postalCode, country,
      mailingStreet1, mailingStreet2, mailingCity, mailingState, mailingPostalCode,
      phone, mobile, contactType;
  private Date dateCreated;

  private Owner owner;

  private List<Project> projects;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}
