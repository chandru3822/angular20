package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CustomField {

  private Long id, companyDataTypeId, listOfValueId, companyId, fieldOrder, createdById, modifiedById,
      customFieldGroupId, ancillaryCustomFieldGroupAssignmentId, customFieldGroupAssignmentId,
      customFieldObjectTypeId, dataTypeId, companySystemListId, scheduleFieldTypeId;
  private List<Long> systemListOptionIds;
  private String fieldName, objectType, groupName, customFieldSqlKey, customFieldSqlReferenceTable, processStepName;
  private Boolean archived, showOnInsert, requireOnInsert, hasListValues, allowMultiple, readonly, customFieldGroupAssignmentReadOnly, useParentData;
  private List<CustomFieldObjectType> customFieldObjectTypes;
  private List<ListOfValue> listOfValues;
  private List<WhiteListedPosition> whiteListedPositions;
  private Date dateCreated, dateModified;
}

