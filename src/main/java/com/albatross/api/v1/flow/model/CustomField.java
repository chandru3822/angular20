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
  private String fieldName, objectType, groupName, customFieldSqlKey, customFieldSqlReferenceTable;
  private Boolean archived, showOnInsert, hasListValues, allowMultiple;
  private List<CustomFieldObjectType> customFieldObjectTypes;
  private List<ListOfValue> listOfValues;
  private Date dateCreated, dateModified;
}

