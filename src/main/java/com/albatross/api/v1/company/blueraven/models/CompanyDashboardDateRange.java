package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.time.Instant;

/**
 * Created by Joseph Canto on 2020-09-15.
 */
@Data
public class CompanyDashboardDateRange {
    private int id;
    private String friendlyName, name, trendText;
    private Instant startDate, endDate, trendStart, trendEnd;

  public CompanyDashboardDateRange(int id, String friendlyName, String name, Instant startDate, Instant endDate, Instant trendStart, Instant trendEnd,
  String trendText) {
    this.id = id;
    this.friendlyName = friendlyName;
    this.name = name;
    this.startDate = startDate;
    this.endDate = endDate;
    this.trendStart = trendStart;
    this.trendEnd = trendEnd;
    this.trendText = trendText;
  }
}
