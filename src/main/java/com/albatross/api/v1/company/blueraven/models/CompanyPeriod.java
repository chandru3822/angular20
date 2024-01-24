package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.time.LocalDate;
import java.util.Date;

@Data
public class CompanyPeriod {
  String label, shortLabel;
  LocalDate startDate, endDate;
}
