package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class CompanyProjectStatusType {

  private Long id, projectStatusTypeId, createdById, companyId, modifiedById;

  private String projectStatusType;

  private Timestamp dateCreated, dateModified;

  private Boolean archived;
}
