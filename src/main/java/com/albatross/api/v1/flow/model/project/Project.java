package com.albatross.api.v1.flow.model.project;

import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.ProjectTag;
import com.albatross.api.v1.flow.model.WhiteListedPosition;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@NoArgsConstructor
public class Project {

  Double latitude, longitude;
  private Long id,
      processId,
      companyId,
      contactId,
      statusTypeId,
      companyProjectStatusTypeId,
      projectStatusTypeId,
      companyStateId,
      companyCountryId,
      createdById;
  private String projectName,
      firstName,
      lastName,
      processName,
      projectStatusType,
      state,
      timeZone,
      country,
      street1,
      street2,
      city,
      postalCode,
      stateAbbreviation,
      createdBy,
      phone,
      mobile,
      companyName,
      companyProjectStatusTypeColor,
      email,
      rootProjectStatusType;
  private String dateCreated;
  private Owner owner;
  private Contact contact;
  private Boolean statusReadOnly, ownerReadOnly;
  private List<ProjectTag> tags;
  private List<WhiteListedPosition> statusReadOnlyWhiteListedPositions,
      ownerReadOnlyWhiteListedPositions;

  // tells server to update geolocation
  private Boolean reloadCoordinates = false;
}
