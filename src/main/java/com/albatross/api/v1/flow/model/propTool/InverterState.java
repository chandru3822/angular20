package com.albatross.api.v1.flow.model.propTool;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by John on 2020-04-10.
 * !Describe Purpose!
 */
@Getter
@Setter
public class InverterState {
  private Long id, inverterId, companyStateId;
  private Double adderAmount;
  private String state;
}

