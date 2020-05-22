package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.IronmanCounts;
import com.albatross.api.v1.company.blueraven.services.CloserDashboardService;

import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

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
}
