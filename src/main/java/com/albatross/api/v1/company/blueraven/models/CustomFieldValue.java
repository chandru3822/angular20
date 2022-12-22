package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.WhiteListedPosition;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

@Data
@NoArgsConstructor
public class CustomFieldValue {

  private Long id,
      sourceId,
      customFieldGroupAssignmentId,
      customFieldGroupId,
      ancillaryCustomFieldGroupAssignmentId,
      customFieldId,
      fieldOrder,
      listOfValueId,
      companyDataTypeId,
      dataTypeId,
      companySystemListId,
      flowCustomFieldId,
      conditionalOnId;

  private Boolean valueWasChanged, required;

  // not sure on these types
  private String fieldName, fieldValue, textValue, richTextValue, customFieldSqlKey, customFieldSql, customFieldSqlSmartlist, ancillaryCustomFieldHint;
  private Long intValue;

  private List<Integer> intArrayValue;

  private BigDecimal numericValue;
  private Boolean booleanValue, hasListValues, useParentData, customFieldGroupAssignmentReadOnly, customFieldGroupAssignmentHidden;
  private Timestamp dateValue, timestampValue;

  private List<ListOfValue> listOfValues;
  private List<Long> systemListOptionIds;
  private List<WhiteListedPosition> whiteListedPositions, hiddenWhiteListedPositions;
}
