package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
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

  private String fieldName, fieldValue, textValue, richTextValue, customFieldSqlKey, ancillaryCustomFieldHint;
  private Long intValue;

  private List<Integer> intArrayValue;

  private BigDecimal numericValue;
  private Boolean booleanValue, hasListValues, readonly, systemReadonly, customFieldGroupAssignmentReadOnly, detailView,
    customFieldGroupAssignmentHidden, showOnInsert, requireOnInsert, required, showOnUserProfile, useParentData, allowNow;

  private Timestamp dateValue, timestampValue;

  private List<WhiteListedPosition> whiteListedPositions, hiddenWhiteListedPositions;
  private List<ListOfValue> listOfValues;
  private List<Long> systemListOptionIds;

  //This data type could change to JsonNode once albatross adds a legit json data type. As of 2022-03-01, it is used
  //only to store the returned Aurora design object
  @JsonIgnore
  private String jsonValue;
}
