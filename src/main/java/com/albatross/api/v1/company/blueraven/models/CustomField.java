package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.ListOfValue;
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
      customFieldGroupId, customFieldGroupAssignmentId, customFieldObjectTypeId, ancillaryCustomFieldGroupAssignmentId;
  private String fieldName, objectType, groupName, processStepName;
  private Boolean archived, showOnInsert, requireOnInsert, showOnUserProfile, hasListValues, allowMultiple, useParentData;
  private List<CustomFieldObjectType> customFieldObjectTypes;
  private List<ListOfValue> listOfValues;
  private Date dateCreated, dateModified;
}

