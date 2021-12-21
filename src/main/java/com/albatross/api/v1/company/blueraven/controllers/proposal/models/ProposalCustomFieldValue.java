package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import com.fasterxml.jackson.databind.JsonNode;

import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;

public record ProposalCustomFieldValue(@NotEmpty Long id, @NotNull JsonNode value) {
}
