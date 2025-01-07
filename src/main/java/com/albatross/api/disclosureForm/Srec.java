package com.albatross.api.disclosureForm;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class Srec {

  private Long
    id,
    proposalNumber,
    projectId;

  private String
    ilSrecDisclosureFormId,
    contactName,
    contactEmail,
    contactPhone,
    projectName,
    projectStateAbbreviation,
    utilityCompanyName,
    loanType,
    projectStreet1,
    projectCity,
    projectPostalCode,
    systemSize,
    systemSizeAc,
    yearOneKwhOutput,
    totalCost;

  private BigDecimal
    loanAmount,
    optionalDownPayment,
    requiredDownPayment,
    srecValue,
    storageSizeKwhPerBattery,
    expectedAnnualElectricityUsage;

  private Boolean
    hasBattery;
}
