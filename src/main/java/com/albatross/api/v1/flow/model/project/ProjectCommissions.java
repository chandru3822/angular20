package com.albatross.api.v1.flow.model.project;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProjectCommissions {

  private String statusType;
  private Double totalByStatus, commissionAtFdc, commissionAtSubstantialCompletion;

}
