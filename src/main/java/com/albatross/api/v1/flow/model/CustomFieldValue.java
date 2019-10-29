package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class CustomFieldValue {

  private Long id, customerId, customFieldGroupAssignmentId, customFieldGroupId,
      customFieldId, fieldOrder, listOfValueId, companyDataTypeId, dataTypeId,
      customFieldSqlKeyId;

  private String fieldName, fieldValue, textValue, customFieldSqlKey;
  private Long intValue;

  private List<Integer> intArrayValue;

  private BigDecimal numericValue;
  private Boolean booleanValue;

  private Timestamp dateValue, timestampValue;

  private List<ListOfValue> listOfValues;

}
