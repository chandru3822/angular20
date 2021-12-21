package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.LinkedHashMap;
import java.util.Map;

@Data
public class ProposalCustomValuesRow {
  private String pk;
  private Long versionId;

  private Map<String, Object> row = new LinkedHashMap<>();

  @JsonAnySetter
  public void setRow(String key, Object value){
    this.row.put(key, value);
  }
}
