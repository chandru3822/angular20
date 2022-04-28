package com.albatross.api.v1.flow.model.project;

import com.albatross.api.v1.flow.model.Attachment;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProjectStatusCount {

  private Long companyProjectStatusTypeId, projectStatusCount;
  private Attachment icon;
  private String companyProjectStatus;

}
