package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class ProductUtilityState {

  private Long id, productId, utilityStateId, companyStateId;
  private String productName, state, utilityCompany;
  private Boolean archived, active;
  private Double fundingCap, targetProductionFactor;
}
