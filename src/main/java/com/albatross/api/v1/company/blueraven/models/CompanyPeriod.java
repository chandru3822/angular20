package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;

@Data
public class CompanyPeriod {
  String label;
  Date startDate, endDate;
}
