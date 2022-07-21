package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import javax.validation.constraints.Size;
import java.util.List;
import java.util.UUID;

public record ProposalCustomGroup(
  @Size(min = 1) List<ProposalCustomFieldValue> values, UUID rowId) {
}
