package com.albatross.api.v1.company.blueraven.controllers.proposal;

import lombok.Data;

/**
 * Represents a custom field value for a proposal process step.
 */
@Data
public class ProposalStepCustomFieldValue {
  private Long fieldId;
  private String fieldName;
  private Object value;
}
