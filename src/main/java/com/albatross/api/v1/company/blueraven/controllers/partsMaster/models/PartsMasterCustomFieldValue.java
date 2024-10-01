package com.albatross.api.v1.company.blueraven.controllers.partsMaster.models;

import com.fasterxml.jackson.databind.JsonNode;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

public record PartsMasterCustomFieldValue(@NotEmpty Long id, @NotNull JsonNode value) {
}
