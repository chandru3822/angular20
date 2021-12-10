package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.time.OffsetDateTime;

@Data
public class ProposalVersion {
  private Long id;
  private String version;
  private String notes;
  private String createdBy, modifiedBy;
  private OffsetDateTime dateCreated, dateModified;
  private boolean isPrimaryVersion;

  @JsonIgnore private Integer proposalVersionStatusId;

  public ProposalVersionStatus getStatus() {
    return ProposalVersionStatus.values()[proposalVersionStatusId];
  }
}
