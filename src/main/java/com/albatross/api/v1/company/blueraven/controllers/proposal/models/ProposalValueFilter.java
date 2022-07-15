package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
public class ProposalValueFilter {
  private Long targetFieldId, targetFlowCustomFieldId, parentFieldId, parentFieldValue;
}
