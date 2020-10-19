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

  private Long id, companyId, companyStateId;
  // todo: @randa this is all kinds of whack. i don't have time to fix it right now. but when loading company states the "id" field is state.id, not company_state.id -- this is used to many places for me to fix right this second. sorry self _rn
  private String state, abbreviation;
  private Boolean active, archived;
  private Double mapLatitude, mapLongitude, mapZoom;
}

