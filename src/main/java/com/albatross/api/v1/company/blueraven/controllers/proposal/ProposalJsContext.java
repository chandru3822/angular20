package com.albatross.api.v1.company.blueraven.controllers.proposal;

import org.graalvm.polyglot.HostAccess;

import java.util.List;
import java.util.Objects;

/**
 * Represents a context for evaluating proposal custom fields in JavaScript.
 * This class provides methods to compare field values with specific criteria.
 */
public class ProposalJsContext {
  private final List<ProposalStepCustomFieldValue> values;

  public ProposalJsContext(List<ProposalStepCustomFieldValue> values) {
    this.values = values;
  }

  /**
   * Determines if the specified fieldId is equal to the provided value.
   *
   * @param  fieldId  the ID of the field to compare
   * @param  value    the value to compare against
   * @return          true if the fieldId is equal to the value, false otherwise
   */
  @HostAccess.Export
  public boolean customFieldHasValue(Long fieldId, Object value) {
    if (fieldId == null) {
      return false;
    }
    return this.values.stream()
      .filter(cfv -> cfv.getFieldId().equals(fieldId))
      .anyMatch(cfv -> Objects.equals(cfv.getValue(), value));
  }
}
