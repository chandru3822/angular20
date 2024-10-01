package com.albatross.api.v1.company.blueraven.controllers.partsMaster.models;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import lombok.Data;

import java.util.LinkedHashMap;
import java.util.Map;

@Data
public class PartsMasterCustomValuesRow {
  private String pk;
  private Long versionId;
  private boolean archived;
  private Map<String, Object> row = new LinkedHashMap<>();

  @JsonAnySetter
  public void setRow(String key, Object value) {
    this.row.put(key, value);
  }
}
