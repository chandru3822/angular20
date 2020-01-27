package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class CustomFieldValue {

  private Long id, sourceId, customFieldGroupAssignmentId, customFieldGroupId,
      customFieldId, fieldOrder, listOfValueId, dataTypeId;

  // not sure on these types
  private String dateValue, timestampValue, fieldName, fieldValue, textValue;
  private Integer intValue, intArrayValue;

  // double??
  private Double numericValue;
  private Boolean booleanValue;

  private List<ListOfValue> listOfValues;

}
