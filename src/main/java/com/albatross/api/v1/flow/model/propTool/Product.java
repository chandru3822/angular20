package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Product {

  private Long id;
  private String productName;
  private Boolean archived;

}
