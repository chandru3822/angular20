package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.Source;
import com.albatross.api.v1.company.blueraven.models.DashboardUserRequest;
import com.albatross.api.v1.company.blueraven.models.IronmanCounts;
import com.albatross.api.v1.company.blueraven.services.CloserDashboardService;

import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by Joseph Canto on 2020-04-30.
 */
@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/closerDashboard")
public class CloserDashboardController {
  @Autowired
  private CloserDashboardService closerDashboardService;

  @GetMapping(value = "/getIronmanFdcCounts")
  public IronmanCounts getIronmanFdcCounts() {
    return closerDashboardService.getIronmanFdcCounts();
  }

  @GetMapping(value = "/finalDesignsCompletedDrilldown")
  public String finalDesignsCompletedDrilldown(@RequestParam Integer quarter) {
    return closerDashboardService.finalDesignsCompletedDrilldown(quarter);
  }

  @GetMapping(value = "/getCloserTableScores")
  public String getCloserTableScores(@RequestParam Integer timeInterval) {
    return closerDashboardService.getCloserTableScores(timeInterval);
  }

  @GetMapping(value = "/getBrsProvidedSources")
  public List<Source> getBrsProvidedSources() {
    return closerDashboardService.getBrsProvidedSources();
  }

  @GetMapping(value = "/getSelfGenSources")
  public List<Source> getSelfGenSources() {
    return closerDashboardService.getSelfGenSources();
  }

  @GetMapping(value = "/getDistricts")
  public String getDistricts(@RequestParam int userId,
                             @RequestParam Boolean setterOverride) {
    return closerDashboardService.getDistricts(userId, setterOverride);
  }

  @GetMapping(value = "/getRegions")
  public String getRegions(@RequestParam int userId,
                           @RequestParam String districts,
                           @RequestParam Boolean setterOverride) {
    return closerDashboardService.getRegions(userId, districts, setterOverride);
  }

  @GetMapping(value = "/getOffices")
  public String getOffices(@RequestParam int userId,
                           @RequestParam String regions,
                           @RequestParam Boolean setterOverride) {
    return closerDashboardService.getOffices(userId, regions, setterOverride);
  }

  @PostMapping(value = "/getReps")
  public String getReps(@RequestBody DashboardUserRequest request) {
    return closerDashboardService.getReps(request);
  }
}
