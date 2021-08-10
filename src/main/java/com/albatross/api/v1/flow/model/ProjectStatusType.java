package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProjectStatusType {

  //oh boy. this is confusing af.  id = companyProjectStatusTypeId.  projectStatusTypeId = rootProjectStatusTypeId
    private Long id, projectStatusTypeId, displayOrder;

    private String projectStatusType, rootProjectStatusType, color;
    private Attachment icon;

    private Boolean archived, isDefault;

}
