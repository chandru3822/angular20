package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProjectDensityResult {

  private Long id;
  private String projectName, projectStatusType, city, state;
  private Double latitude, longitude;
}
