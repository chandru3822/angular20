package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.Data;

@Data
public class ProposalValueFilter {
  private Long targetFieldId, targetFlowCustomFieldId, parentFieldId, parentFieldValue;
}
