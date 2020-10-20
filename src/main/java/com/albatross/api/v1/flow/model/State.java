package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class State {

  private Long id, companyId, stateId;
  private String state, abbreviation;
  private Boolean active, archived;
  private Double mapLatitude, mapLongitude, mapZoom;
}

