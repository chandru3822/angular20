package com.albatross.api.v1.flow.model.project;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProjectStatusCount {

  private Long companyProjectStatusTypeId, projectStatusCount;
  private String companyProjectStatus, iconTag;
  private ProjectCommissions commissions;

}
