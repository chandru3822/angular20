package com.albatross.api.v1.company.blueraven.services;

import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Setter
@Getter
public class SolargrafProjectRequest {
  private String name;
  private Map<String, String> address;
  private Long projectId;

  public SolargrafProjectRequest(String name, Map<String, String> address, Long projectId) {
    this.name = name;
    this.address = address;
    this.projectId = projectId;
  }

}
