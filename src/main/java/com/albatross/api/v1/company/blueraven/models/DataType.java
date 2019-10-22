package com.albatross.api.v1.company.blueraven.models;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class DataType {

  private Long id;
  private String dataType;
  private Boolean hasListValues, allowMultiple, archived;
}

