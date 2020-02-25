package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class ProductUtilityState {

  private Long id;
  private String productId, utilityStateId;
  private Boolean archived;
  private Double fundingCap, targetProductionFactor;
}
