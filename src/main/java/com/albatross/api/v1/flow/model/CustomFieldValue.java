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

  private Long id, contactId, customFieldGroupAssignmentId, customFieldGroupId,
      customFieldId, fieldOrder, listOfValueId, companyDataTypeId, dataTypeId, uniqueBehaviorTypeId,
      companySystemListId, projectProcessStepId, scheduleFieldTypeId, ancillaryCustomFieldGroupAssignmentId;

  private String fieldName, fieldValue, textValue, customFieldSqlKey;
  private Long intValue;

  private List<Integer> intArrayValue;

  private BigDecimal numericValue;
  private Boolean booleanValue, hasListValues, readonly, customFieldGroupAssignmentReadOnly, detailView,
    customFieldGroupAssignmentHidden, showOnInsert, requireOnInsert, useParentData;

  private Timestamp dateValue, timestampValue;

  private List<WhiteListedPosition> whiteListedPositions, hiddenWhiteListedPositions;
  private List<ListOfValue> listOfValues;
  private List<Long> systemListOptionIds;

}
