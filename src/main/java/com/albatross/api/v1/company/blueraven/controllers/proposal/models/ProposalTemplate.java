package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.util.List;

@Data
@Accessors(chain = true)
public class ProposalTemplate implements Serializable {
  private Long id;
  private String templateName;
  private ProposalTheme theme;
  private List<ProposalTemplateBlock> blocks;
}
