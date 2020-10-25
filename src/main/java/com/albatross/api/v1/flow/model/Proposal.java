package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.model.propTool.Adder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Proposal {

  private Long id, projectId, companyStateId, utilityCompanyId, productId, panelId, inverterId, auroraDesignId, proposalNumber;
  private String customerName, address, city, zipCode, phone, email, promotion, notes, proposalCreatedBy, qaCompletedBy;

  private Boolean monitor, addersChanged;

  private List<Adder> adders;

  private int loanTerm, numberOfEcobees, numberOfLeds, numberOfPanels;

  private Double interestRate, downPayment, yearOutput, totalSystemPrice, offsetVal, productionFactor;

  private LocalDate dateCreated;
}
