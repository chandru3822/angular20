package com.albatross.api.v1.company.blueraven.services;

import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Setter
@Getter
public class SolargrafProjectRequest {
  private String name;
  private Map<String, String> address;

  public SolargrafProjectRequest(String name, Map<String, String> address) {
    this.name = name;
    this.address = address;
  }

}
