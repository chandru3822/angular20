package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class ProposalDesign {

  private Long projectId, projectProcessStepId;
  private Long offset = 0L;
  private String projectName, dateCreated;
  private List<Proposal> proposals;
}
