package com.albatross.api.v1.flow.model.propTool;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class UtilityState {

  private Long id, utilityId, companyStateId;
  private String state;
  private Double costPerKwh, escalator;
  private Boolean archived;
}

