package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProjectStatusCount {

  private Long companyProjectStatusTypeId, projectStatusCount;
  private Attachment icon;
  private String companyProjectStatus;

}
