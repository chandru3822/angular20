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
  private String projectName;
  private List<Proposal> proposals;
}
