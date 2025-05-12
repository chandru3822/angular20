package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

@Data
@NoArgsConstructor
public class Proposal {
  private Long id, proposalNbr, projectId, projectProcessStepId, proposalVersionId, revisionNumber, stateId, utilityCompanyId, proposalTemplateId,
    objectCategoryId, proposalLogHistoryId;
  private String projectName, name, email, version, proposalDetails;
  private OffsetDateTime dateCreated, dateModified, projectAddersLastReviewedDate;
  private BigDecimal maxDiscountAmount;
  private boolean locked, archived, creditCheckSubmitted, financeDocsSent, installationAgreementSent, external;
  private List<CustomFieldGroup> customFieldGroups;

  public String getDisplayName() {

    String name = this.name;
    if (name == null) {
      name = "New Proposal";
    }

    if (this.revisionNumber != null && this.revisionNumber > 0) {
      name += " (%d)".formatted(this.revisionNumber);
    }
    name = name + " - %d".formatted(this.proposalNbr);

    return name;
  }
}
