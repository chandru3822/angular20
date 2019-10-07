package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class DataTypeRequirement {

  private Long id, dataTypeId;
  private String dataTypeValue, dataType;
  private Boolean secondaryRequirement, archived;
}

