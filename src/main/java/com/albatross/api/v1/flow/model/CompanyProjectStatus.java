package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CompanyProjectStatus {

  //oh boy. this is confusing af.  id = companyProjectStatusTypeId.  projectStatusTypeId = rootProjectStatusTypeId
    private Long id, projectStatusTypeId;

    private String projectStatusType, rootProjectStatusType;

    private Boolean archived;

}
