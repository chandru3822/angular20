package com.albatross.api.v1.flow.model.smartlist;

import lombok.Data;

import java.sql.Timestamp;

@Data
public class SmartlistMetric {
  private Long id, smartlistId, createdById;

  private String createdBy;

  private Timestamp dateCreated;
}
