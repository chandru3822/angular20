package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
public class Project {

  private Long id, processId, companyId, contactId, statusTypeId, companyProjectStatusTypeId, projectStatusTypeId, stateId, countryId;
  private String projectName, processName, projectStatusType, state, timeZone, country, street1, street2, city, postalCode;
  Double latitude, longitude;
  private LocalDate dateCreated;

  private Contact contact;
}
