package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class CustomFieldValue {

  private Long id, customerId, customFieldGroupAssignmentId, customFieldGroupId,
      customFieldId, fieldOrder, listOfValueId, companyDataTypeId, dataTypeId,
      customFieldSqlKeyId, systemListTypeId;

  // not sure on these types
  private String dateValue, timestampValue, fieldName, fieldValue, textValue, customFieldSqlKey;
  private Integer intValue, intArrayValue;
  // double??
  private Double numericValue;
  private Boolean booleanValue;

  private List<ListOfValue> listOfValues;
  private List<Long> systemListOptionIds;

}
