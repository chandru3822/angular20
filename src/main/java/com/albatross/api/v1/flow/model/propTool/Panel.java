package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Panel {

  private Long id;
  private Integer wattage;
  private String panelName, panelType, panelColor;
  private Boolean archived, active;
  private List<PanelState> panelStates;

}
