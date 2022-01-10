package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
public class CustomField {

  private Long id,
      companyDataTypeId,
      listOfValueId,
      companyId,
      fieldOrder,
      createdById,
      modifiedById,
      customFieldGroupId,
      ancillaryCustomFieldGroupAssignmentId,
      customFieldGroupAssignmentId,
      customFieldObjectTypeId,
      dataTypeId,
      companySystemListId,
      scheduleFieldTypeId;
  private List<Long> systemListOptionIds;
  private String fieldName,
      fieldCode,
      objectType,
      groupName,
      customFieldSqlKey,
      customFieldSqlReferenceTable,
      processStepName,
      dataType;
  private Boolean archived,
      showOnInsert,
      requireOnInsert,
      showOnUserProfile,
      hasListValues,
      allowMultiple,
      readonly,
      customFieldGroupAssignmentReadOnly,
      customFieldGroupAssignmentHidden,
      useParentData,
      sortListValuesAlphabetically,
      lazyLoadValues;
  private List<CustomFieldObjectType> customFieldObjectTypes;
  private List<ListOfValue> listOfValues;
  private List<WhiteListedPosition> whiteListedPositions, hiddenWhiteListedPositions;
  private Date dateCreated, dateModified;

  public boolean shouldHaveListOfValues() {
    if (this.listOfValues != null && !this.listOfValues.isEmpty()) {
      return true;
    }

    if (this.customFieldSqlKey != null) {
      return true;
    }

    return this.companySystemListId != null;
  }
}
