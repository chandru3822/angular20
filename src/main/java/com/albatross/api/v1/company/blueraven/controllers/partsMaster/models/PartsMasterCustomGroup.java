package com.albatross.api.v1.company.blueraven.controllers.partsMaster.models;

import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.UUID;

public record PartsMasterCustomGroup(
  @Size(min = 1) List<PartsMasterCustomFieldValue> values, UUID rowId) {
}
