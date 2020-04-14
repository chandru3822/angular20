package com.albatross.api.v1.flow.model.propTool;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class PanelState {

  private Long id, panelId, companyStateId;
  private Double adderAmount;
  private String state;
  private boolean archived;
}

