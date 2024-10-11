package com.albatross.api.v1.flow.model.project;

import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@NoArgsConstructor
public class Project {

  private Double latitude, longitude, commissionsOutstanding;
  private Long id,
    processId,
    companyProcessId,
    companyId,
    contactId,
    statusTypeId,
    companyProjectStatusTypeId,
    projectStatusTypeId,
    companyStateId,
    companyCountryId,
    objectCategoryId,
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
    rootProjectStatusType,
    objectCategory,
    ownerName;
  private String dateCreated;
  private Owner owner;
  private Contact contact;
  private Boolean statusReadOnly, ownerReadOnly, statusReadOnlyAllow, ownerReadOnlyAllow;
  private List<ProjectTag> tags;
  private List<ChildCompanyProcess> childCompanyProcesses;
  private Project parentProject;
  private List<Project> childProjects;
  private List<WhiteListedPosition> statusReadOnlyWhiteListedPositions,
    ownerReadOnlyWhiteListedPositions;

  // tells server to update geolocation
  private Boolean reloadCoordinates = false;
}
