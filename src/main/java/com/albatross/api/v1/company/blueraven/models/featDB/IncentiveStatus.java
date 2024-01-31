package com.albatross.api.v1.company.blueraven.models.featDB;

import lombok.Data;

@Data
public class IncentiveStatus {
  private Long id;
  private String status;
  private Boolean archived;
}
