package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class CompanyConfigurationValue {

  private Long id, companyId;
  private String name, code, value;
  private Boolean archived;
}
