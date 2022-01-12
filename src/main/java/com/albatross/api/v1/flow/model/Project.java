package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class Project {

  private Long id, processId, companyId, contactId, statusTypeId, companyProjectStatusTypeId, projectStatusTypeId, companyStateId, companyCountryId, createdById;
  private String projectName, processName, projectStatusType, state, timeZone, country, street1, street2, city, postalCode, stateAbbreviation, createdBy,
    phone, mobile, companyName, companyProjectStatusTypeColor, email, rootProjectStatusType;
  Double latitude, longitude;
  private String dateCreated;
  private Owner owner;
  private Contact contact;
  private Boolean statusReadOnly, ownerReadOnly;
  private List<WhiteListedPosition> statusReadOnlyWhiteListedPositions, ownerReadOnlyWhiteListedPositions;

  //tells server to update geolocation
  private Boolean reloadCoordinates = false;
}
