package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class CustomFieldValue {

  private Long id, customerId, customFieldGroupAssignmentId, customFieldGroupId,
      customFieldId, fieldOrder, listOfValueId, companyDataTypeId, dataTypeId;

  // not sure on these types
  private String dateValue, timestampValue, fieldName, fieldValue;
  private Integer intValue, intArrayValue;
  // double??
  private Double numericValue;
  private Boolean booleanValue;

}
