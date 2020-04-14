package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Inverter {

  private Long id;
  private String inverterName, brand, inverterType;
  private Boolean archived, active;
  private List<InverterState> inverterStates;

}
