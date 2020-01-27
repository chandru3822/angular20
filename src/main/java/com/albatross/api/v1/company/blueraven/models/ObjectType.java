package com.albatross.api.v1.company.blueraven.models;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ObjectType {

  private Long id;
  private String objectType, objectCode;
  private Boolean archived;
}

