package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Feature {

  private Long id;
  private String featureName, featureCode;
  private Boolean archived, isSystem;

}

