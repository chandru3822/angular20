package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProposalAdderDetail {
  private Long id;
  private String adderType, fieldName;
  private Boolean selectedProjectAdder, selectedProposalAdder;
  private Double selectedAdderAmount, customProposalAdderAmount, customProjectAdderAmount, autoAppliedAdderAmount;
}
