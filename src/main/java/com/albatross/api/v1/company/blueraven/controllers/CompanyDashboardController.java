package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CompanyDashboardTargets;
import com.albatross.api.v1.company.blueraven.services.CompanyDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/companyDashboard")
@RequiredArgsConstructor
public class CompanyDashboardController {
  private final CompanyDashboardService companyDashboardService;

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
                                   @RequestParam String endDate,
                                   @RequestParam(required = false) Long targetTypeId) {
    return companyDashboardService.getDashboardValues(startDate, endDate, targetTypeId);
  }

  @GetMapping(value = "/drilldownData")
  public String getDrilldownValues(@RequestParam String startDate,
                                   @RequestParam String endDate,
                                   @RequestParam Long milestoneTypeId,
                                   @RequestParam Boolean loadPartners) {
    return companyDashboardService.getDrilldownValues(startDate, endDate, milestoneTypeId, loadPartners);
  }
}
