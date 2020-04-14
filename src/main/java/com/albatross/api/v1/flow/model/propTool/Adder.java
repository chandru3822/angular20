package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Adder {
  private Long id, adderTypeId;
  private String adderName, state, adderTypeLabel;
  private Boolean active, archived;
  private List<AdderState> adderStates;

}
