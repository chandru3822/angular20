package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import org.json.JSONObject;

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
    srecValue;
}
