package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CompanyDashboardDrillData;
import com.albatross.api.v1.company.blueraven.models.CompanyDashboardTargets;
import com.albatross.api.v1.company.blueraven.services.CompanyDashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/companyDashboard")
public class CompanyDashboardController {
  @Autowired
  private CompanyDashboardService companyDashboardService;

  @GetMapping(value = "/targets")
  public List<CompanyDashboardTargets> getTargets() {
    return companyDashboardService.getTargets();
  }

  @PostMapping(value = "/updateTargets")
  public void updateTargets(@RequestBody List<CompanyDashboardTargets> targetValueRows) {
    companyDashboardService.updateTargets(targetValueRows);
  }

  @GetMapping(value = "/dashboardValues")
  public String getDashboardValues(@RequestParam String startDate,
                                   @RequestParam String endDate) {
    return companyDashboardService.getDashboardValues(startDate, endDate);
  }

  @GetMapping(value = "/drilldownData")
  public List<CompanyDashboardDrillData> getDrilldownData(@RequestParam String startDate,
                                                          @RequestParam String endDate,
                                                          @RequestParam String milestone,
                                                          @RequestParam String column) {
    return companyDashboardService.getDrilldownData(startDate, endDate, milestone, column);
  }
}
