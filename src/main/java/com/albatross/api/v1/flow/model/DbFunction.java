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
public class DbFunction {

  private Long id, returnDataTypeId, dbFunctionTypeId;
  private String functionName;
  private Boolean archived;
  private List<DbFunctionParam> dbFunctionParams;
}

