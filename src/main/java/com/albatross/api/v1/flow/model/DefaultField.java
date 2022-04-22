package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class DefaultField {

  private Long id, dataTypeId, objectTypeId;
  private String fieldName, columnName, propertyName;
  private Boolean archived, watchedByTrigger;

}

