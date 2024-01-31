package com.albatross.api.v1.company.blueraven.models.featDB;

import lombok.Data;

@Data
public class IncentiveType {
  private Long id;
  private String type;
  private Boolean archived;
}
