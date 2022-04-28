package com.albatross.api.v1.flow.model.function;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class DbFunctionType {

  private Long id;
  private String functionType;
  private Boolean archived;
}

