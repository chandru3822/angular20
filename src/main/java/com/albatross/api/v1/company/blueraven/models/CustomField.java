package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.WhiteListedPosition;
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
    customFieldGroupId, customFieldGroupAssignmentId, customFieldObjectTypeId, ancillaryCustomFieldGroupAssignmentId, dataTypeId, conditionalOnId;
  private String fieldName, objectType, groupName, processStepName;
  private Double minValue, maxValue;
  private Boolean archived, showOnInsert, requireOnInsert, required, showOnUserProfile, hasListValues, allowMultiple, useParentData, customFieldGroupAssignmentReadOnly, customFieldGroupAssignmentHidden;
  private List<CustomFieldObjectType> customFieldObjectTypes;
  private List<ListOfValue> listOfValues;
  private List<WhiteListedPosition> whiteListedPositions, hiddenWhiteListedPositions;
  private Date dateCreated, dateModified;
}

