package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SmartlistListOfValue extends ListOfValue {

  private Long rootStatusTypeId;

  private boolean rootStatusType;
}
