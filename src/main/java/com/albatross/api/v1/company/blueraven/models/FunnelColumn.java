package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class FunnelColumn {
    private Long id, displayOrder, dataTypeId;
    private String title, fieldName, dataType;

  public FunnelColumn(Long id, String title, String fieldName, Long displayOrder, Long dataTypeId, String dataType) {
    this.id = id;
    this.title = title;
    this.fieldName = fieldName;
    this.displayOrder = displayOrder;
    this.dataTypeId = dataTypeId;
    this.dataType = dataType;
  }
}
