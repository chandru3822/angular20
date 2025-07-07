package com.albatross.api.v1.company.blueraven.services;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class SolargrafProjectResponse {
  private String projectUrl;
  private boolean success;
  private String message;
  private String projectId;
  private String proposalId;

  public SolargrafProjectResponse(String projectUrl, boolean success, String message) {
    this.projectUrl = projectUrl;
    this.success = success;
    this.message = message;
  }

  public SolargrafProjectResponse(String projectUrl, boolean success, String message, String projectId, String proposalId) {
    this.projectUrl = projectUrl;
    this.success = success;
    this.message = message;
    this.projectId = projectId;
    this.proposalId = proposalId;
  }

}
