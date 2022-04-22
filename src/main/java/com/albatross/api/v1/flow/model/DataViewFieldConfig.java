package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class DataViewFieldConfig {

  private Long id, fieldConfigId, defaultFieldId, customFieldGroupAssignmentId,
    updateFirstValueOnlyId, processStepEventId, dataTypeId, objectTypeId;
  private String fieldToUpdate, fieldName, displayName, columnName, propertyName;
  private Boolean archived, watchedByTrigger, updateFirstValueOnly;
  private List<DataViewChildFieldConfig> childFieldConfigs;

}

