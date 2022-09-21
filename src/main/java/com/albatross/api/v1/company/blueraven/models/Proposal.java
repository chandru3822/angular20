package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class Proposal {
  private Long id, proposalNbr, projectId, projectProcessStepId, proposalVersionId, revisionNumber;
  private String projectName, name, email, version, dateCreated;
  private boolean locked, archived, creditCheckSubmitted, financeDocsSent, installationAgreementSent;
  private List<CustomFieldGroup> customFieldGroups;

  public String getDisplayName() {

    String name = this.name;
    if (name == null) {
      name = "New Proposal";
    }

    if (this.revisionNumber != null && this.revisionNumber > 0) {
      name += String.format(" (%d)", this.revisionNumber);
    }
    name = name + String.format(" - %d", this.proposalNbr);

    return name;
  }
}
