package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Proposal {

  private Long id, projectId, projectProcessStepId, proposalVersionId;
  private String projectName, version, dateCreated;
  private List<CustomFieldGroup> customFieldGroups;
}
