package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Product {

  private Long id, termLength, companyId;
  private String productName;
  private Double interestRate, dealerFee;
  private Boolean archived, active;

}
