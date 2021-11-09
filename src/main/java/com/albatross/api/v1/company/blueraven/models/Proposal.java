package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Proposal {

  private Long id, projectId;
  private String projectName;
}
