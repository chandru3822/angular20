package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.time.LocalDate;

@Data
public class Triumvirate {
  LocalDate currentPeriodStart, currentPeriodEnd, lastPeriodStart, lastPeriodEnd,
  penultimatePeriodStart, penultimatePeriodEnd, currentQuarterStart, currentQuarterEnd,
  lastQuarterStart, lastQuarterEnd, penultimateQuarterStart, penultimateQuarterEnd;
}
