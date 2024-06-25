package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-09-15.
 */
@Data
public class CloserDashboardDateRange {
    private int id;
    private String friendlyName, name, trendText;
    private LocalDate startDate, endDate, trendStart, trendEnd;

    private List<CompanyPeriod> periodList;

  public CloserDashboardDateRange(int id, String friendlyName, String name, LocalDate startDate, LocalDate endDate, LocalDate trendStart, LocalDate trendEnd,
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

  public CloserDashboardDateRange(){};
}
