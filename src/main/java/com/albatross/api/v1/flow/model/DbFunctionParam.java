package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class DbFunctionParam {

  private Long id, dbFunctionId, displayOrder, dataTypeId, parameterTypeId;
  private String parameterName;
  private Boolean archived;
}

