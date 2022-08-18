package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class Proposal {
  private Long id, proposalNbr, projectId, projectProcessStepId, proposalVersionId;
  private String projectName, name, email, version, dateCreated;
  private boolean locked, archived, creditCheckSubmitted, financeDocsSent, installationAgreementSent;
  private List<CustomFieldGroup> customFieldGroups;
}
