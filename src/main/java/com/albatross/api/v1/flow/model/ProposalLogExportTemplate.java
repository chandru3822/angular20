package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@JsonPropertyOrder({"Project ID", "Proposal Number", "Number of Panels", "Panel Wattage", "Annual Production"})
public class ProposalLogExportTemplate {

  public static ProposalLogExportTemplate from(ProposalLog other) {
    return ProposalLogExportTemplate.builder()
      .projectId(other.getProjectId().toString())
      .proposalNumber(other.getProposalNumber().toString())
      .numberOfPanels(Integer.toString(other.getNumberOfPanels()))
      .panelWattage(Integer.toString(other.getPanelWattage()))
      .annualProduction(Integer.toString(other.getAnnualProduction()))
      .build();
  }

  @JsonProperty("Project ID")
  private String projectId;

  @JsonProperty("Proposal Number")
  private String proposalNumber;

  @JsonProperty("Number of Panels")
  private String numberOfPanels;

  @JsonProperty("Panel Wattage")
  private String panelWattage;

  @JsonProperty("Annual Production")
  private String annualProduction;

}
