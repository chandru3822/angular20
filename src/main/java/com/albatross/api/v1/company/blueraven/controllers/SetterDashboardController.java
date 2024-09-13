package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.SetterDashboardService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


import java.util.List;

/**
 * Created by Joseph Canto on 2020-07-06.
 */
@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/setterDashboard")
@RequiredArgsConstructor
public class SetterDashboardController {

  private final SetterDashboardService setterDashboardService;

  @GetMapping(value = "/getIncentivePitchCounts")
  public IncentiveCounts getIncentivePitchCounts(@RequestParam Boolean isSetterMgr,
                                                 @RequestParam(required = false) Integer setterMgrOfficeId) {
    return setterDashboardService.getIncentivePitchCounts(isSetterMgr, setterMgrOfficeId);
  }

  @GetMapping(value = "/pitchesDrilldown")
  public String pitchesDrilldown(@RequestParam int quarter,
                                 @RequestParam Boolean isSetterMgr,
                                 @RequestParam(required = false) Integer setterMgrOfficeId) {
    return setterDashboardService.pitchesDrilldown(quarter, isSetterMgr, setterMgrOfficeId);
  }

  @GetMapping(value = "/getPerformanceReport")
  public SetterPerformance getPerformanceReport(@RequestParam String startDate,
                                                @RequestParam String endDate) {
    return setterDashboardService.getPerformanceReport(startDate, endDate);
  }

  @GetMapping(value = "/getOfficePerformanceReport")
  public SetterPerformance getOfficePerformanceReport(@RequestParam String startDate,
                                        @RequestParam String endDate) {
    return setterDashboardService.getOfficePerformanceReport(startDate, endDate);
  }

  @GetMapping(value = "/topReps")
  public List<TopRep> topReps(@RequestParam String startDate,@RequestParam String endDate,@RequestParam int limit) {
    return setterDashboardService.topReps(startDate, endDate, limit);
  }


  @GetMapping(value = "/officeRanking")
  public List<OfficeRank> officeRanking(@RequestParam String startDate,@RequestParam String endDate,@RequestParam int limit) {
    return setterDashboardService.officeRanking(startDate, endDate, limit);
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

  @PostMapping(value = "/funnel")
  public String loadFunnel(@RequestBody FunnelRequest funnelRequest) {
    return setterDashboardService.loadFunnel(funnelRequest);
  }

  @PostMapping(value = "/upcomingAppointments")
  public String loadUpcomingAppointments(@RequestBody FunnelRequest funnelRequest) {
    return setterDashboardService.loadUpcomingAppointments(funnelRequest);
  }

  @PostMapping(value = "/funnelDrilldown")
  public String funnelDrilldown(@RequestBody FunnelRequest funnelRequest) {
    return setterDashboardService.funnelDrilldown(funnelRequest);
  }

  @GetMapping(value = "/dropdownValues")
  public List<CloserDashboardDateRange> getDropdownValues(@RequestParam java.time.LocalDate today) {
    return setterDashboardService.getDropdownValues(today);
  }
}
