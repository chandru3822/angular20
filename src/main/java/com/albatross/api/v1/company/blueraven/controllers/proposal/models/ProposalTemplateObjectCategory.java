package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.Data;

@Data
public class ProposalTemplateObjectCategory {
  private Long id;
  private String objectCategory;
  private Long templateId;
  private String templateName;
}
