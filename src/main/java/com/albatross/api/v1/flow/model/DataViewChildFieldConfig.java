package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class DataViewChildFieldConfig {

  private Long id, dataTypeId, uniqueBehaviorTypeId, dataViewFieldConfigId;
  private String fieldToUpdate, dataType, uniqueBehaviorType, uniqueBehaviorTypeDescription, displayName;
  private Boolean archived;

}

