package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CustomFieldGroup {

  private Long id, customFieldObjectTypeId;
  private String objectType;
  private Boolean archived;
}

