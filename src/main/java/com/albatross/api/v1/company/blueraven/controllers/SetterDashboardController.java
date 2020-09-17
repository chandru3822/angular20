package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.DashboardUserRequest;
import com.albatross.api.v1.company.blueraven.models.IronmanCounts;
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

  @GetMapping(value = "/getIronmanPitchCounts")
  public IronmanCounts getIronmanPitchCounts(@RequestParam Boolean isSetterMgr,
                                             @RequestParam (required = false) Integer setterMgrOfficeId) {
    return setterDashboardService.getIronmanPitchCounts(isSetterMgr, setterMgrOfficeId);
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

  @GetMapping(value = "/getDistricts")
  public String getDistricts(@RequestParam int userId) {
    return setterDashboardService.getDistricts(userId);
  }

  @GetMapping(value = "/getRegions")
  public String getRegions(@RequestParam int userId,
                           @RequestParam String districts) {
    return setterDashboardService.getRegions(userId, districts);
  }

  @GetMapping(value = "/getOffices")
  public String getOffices(@RequestParam int userId,
                           @RequestParam String regions) {
    return setterDashboardService.getOffices(userId, regions);
  }

  @PostMapping(value = "/getReps")
  public String getReps(@RequestBody DashboardUserRequest request) {
    return setterDashboardService.getReps(request);
  }
}
