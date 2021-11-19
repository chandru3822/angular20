package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.DashboardUserRequest;
import com.albatross.api.v1.company.blueraven.models.FunnelRequest;
import com.albatross.api.v1.company.blueraven.models.IncentiveCounts;
import com.albatross.api.v1.company.blueraven.services.SetterDashboardService;
import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * Created by Joseph Canto on 2020-07-06.
 */
@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/setterDashboard")
public class SetterDashboardController {
  @Autowired
  private SetterDashboardService setterDashboardService;

  @GetMapping(value = "/getIncentivePitchCounts")
  public IncentiveCounts getIncentivePitchCounts(@RequestParam Boolean isSetterMgr,
                                             @RequestParam (required = false) Integer setterMgrOfficeId) {
    return setterDashboardService.getIncentivePitchCounts(isSetterMgr, setterMgrOfficeId);
  }

  @GetMapping(value = "/pitchesDrilldown")
  public String pitchesDrilldown(@RequestParam int quarter,
                                 @RequestParam Boolean isSetterMgr,
                                 @RequestParam (required = false) Integer setterMgrOfficeId) {
    return setterDashboardService.pitchesDrilldown(quarter, isSetterMgr, setterMgrOfficeId);
  }

  @GetMapping(value = "/getPerformanceReport")
  public String getPerformanceReport(@RequestParam String startDate,
                                     @RequestParam String endDate) {
    return setterDashboardService.getPerformanceReport(startDate, endDate);
  }

  @GetMapping(value = "/repToBeat")
  public String repToBeat(@RequestParam int userId,
                          @RequestParam String startDate,
                          @RequestParam String endDate) {
    return setterDashboardService.repToBeat(userId, startDate, endDate);
  }

  @GetMapping(value = "/getMgrPerformanceReport")
  public String getMgrPerformanceReport(@RequestParam Integer officeId,
                                        @RequestParam String startDate,
                                        @RequestParam String endDate) {
    return setterDashboardService.getMgrPerformanceReport(officeId, startDate, endDate);
  }

  @GetMapping(value = "/officeToBeat")
  public String officeToBeat(@RequestParam int officeId,
                                   @RequestParam String startDate,
                                   @RequestParam String endDate) {
    return setterDashboardService.officeToBeat(officeId, startDate, endDate);
  }

  @GetMapping(value = "/topReps")
  public String topReps(@RequestParam int limit, @RequestParam int days) {
    return setterDashboardService.topReps(limit, days);
  }

  @GetMapping(value = "/topOffices")
  public String topOffices(@RequestParam int limit, @RequestParam int days) {
    return setterDashboardService.topOffices(limit, days);
  }

  @GetMapping(value = "/officeRanking")
  public String officeRanking(@RequestParam int limit, @RequestParam int days) {
    return setterDashboardService.officeRanking(limit, days);
  }

  @PostMapping(value = "/getAreas")
  public String getAreas(@RequestBody DashboardUserRequest request) {
    return setterDashboardService.getAreas(request);
  }

  @PostMapping(value = "/getRegions")
  public String getRegions(@RequestBody DashboardUserRequest request) {
    return setterDashboardService.getRegions(request);
  }

  @PostMapping(value = "/getDistricts")
  public String getDistricts(@RequestBody DashboardUserRequest request) {
    return setterDashboardService.getDistricts(request);
  }

  @PostMapping(value = "/getOffices")
  public String getOffices(@RequestBody DashboardUserRequest request) {
    return setterDashboardService.getOffices(request);
  }

  @PostMapping(value = "/getReps")
  public String getReps(@RequestBody DashboardUserRequest request) {
    return setterDashboardService.getReps(request);
  }

  @PostMapping(value = "/funnel/standard")
  public String funnelStandard(@RequestBody FunnelRequest funnelRequest) {
    return setterDashboardService.funnelStandard(funnelRequest);
  }

  @PostMapping(value = "/funnelDrilldown/standard")
  public String funnelDrilldownStandard(@RequestBody FunnelRequest funnelRequest) {
    return setterDashboardService.funnelDrilldownStandard(funnelRequest);
  }

  @PostMapping(value = "/funnel/cohort")
  public String funnelCohort(@RequestBody FunnelRequest funnelRequest) {
    return setterDashboardService.funnelCohort(funnelRequest);
  }

  @PostMapping(value = "/funnelDrilldown/cohort")
  public String funnelDrilldownCohort(@RequestBody FunnelRequest funnelRequest) {
    return setterDashboardService.funnelDrilldownCohort(funnelRequest);
  }
}
