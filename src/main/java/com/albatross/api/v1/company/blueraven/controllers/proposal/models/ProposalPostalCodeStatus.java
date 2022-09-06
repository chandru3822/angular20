package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.Data;

@Data
public class ProposalPostalCodeStatus {
  Long id, processStepStatusTypeId;
  String processStepStatusType, comments;
  boolean approved;
}
