package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class ProposalLog {

  private Long id, projectId, proposalNumber;

  private int numberOfPanels, panelWattage, annualProduction;

  private LocalDate dateCreated;
}
