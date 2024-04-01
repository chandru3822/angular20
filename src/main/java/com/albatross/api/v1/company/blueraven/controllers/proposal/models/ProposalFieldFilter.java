package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ProposalFieldFilter {
  private Long fieldId;
  private Object value;
  private Long intValue, intArrayValue;

  @Override
  public String toString() {
    StringBuilder builder = new StringBuilder();
    builder.append("(")
      .append(fieldId)
      .append(",");

    if (value != null) {
      builder.append(value);
    }
    builder.append(",");

    if (intValue != null) {
      builder.append(intValue);
    }
    builder.append(",");

    if (intArrayValue != null) {
      builder.append(intArrayValue);
    }
    builder.append(")");
    return builder.toString();
  }
}
