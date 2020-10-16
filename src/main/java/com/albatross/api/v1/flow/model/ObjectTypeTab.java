package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ObjectTypeTab {

  private Long id, companyObjectTypeId, displayOrder;
  private String tabName;
  private Boolean archived;
}
