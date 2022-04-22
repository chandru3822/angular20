package com.albatross.api.v1.flow.model.project;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProjectDensityResult {

  private Long id;
  private String projectName, projectStatusType, city, state, street1, postalCode;
  private Double latitude, longitude;
}
