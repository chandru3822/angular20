package com.albatross.api.v1.flow.model.project;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class ProjectStatusType {

  //oh boy. this is confusing af.  id = companyProjectStatusTypeId.  projectStatusTypeId = rootProjectStatusTypeId
  private Long id, projectStatusTypeId, displayOrder;
  private String projectStatusType, rootProjectStatusType, description, iconTag;
  private Boolean archived, isDefault, isMilestone;
  private List<Long> objectCategoryIds;
}
