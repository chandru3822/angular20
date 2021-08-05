package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.CloserDashboardService;
import com.albatross.api.v1.flow.model.Org;
import com.albatross.api.v1.flow.model.PostalCodeZone;
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

  @GetMapping(value = "/getIncentiveFdcCounts")
  public IncentiveCounts getIncentiveFdcCounts() {
    return closerDashboardService.getIncentiveFdcCounts();
  }

  @GetMapping(value = "/finalDesignsCompletedDrilldown")
  public String finalDesignsCompletedDrilldown(@RequestParam Integer quarter) {
    return closerDashboardService.finalDesignsCompletedDrilldown(quarter);
  }

  @GetMapping(value = "/getRoundRobins")
  public List<PostalCodeZone> getRoundRobins() {
    return closerDashboardService.getRoundRobins();
  }

  @GetMapping(value = "/getRoundRobinLeadAllocationRank")
  public List<RoundRobinLeadAllocationScores> getRoundRobinLeadAllocationRank(@RequestParam Integer postalCodeZoneId,
                                                                      @RequestParam Integer timeInterval) {
    return closerDashboardService.getRoundRobinLeadAllocationRank(postalCodeZoneId, timeInterval);
  }

  @GetMapping(value = "/getCloserOffices")
  public List<Org> getCloserOffices(@RequestParam(required = false) Long userOrgId) {
    return closerDashboardService.getCloserOffices(userOrgId);
  }

  @GetMapping(value = "/getCloserTableScores")
  public String getCloserTableScores(@RequestParam Integer timeInterval,
                                     @RequestParam Boolean officeFdcRank,
                                     @RequestParam(required = false) Long selectedOrgId) {
    return closerDashboardService.getCloserTableScores(timeInterval, officeFdcRank, selectedOrgId);
  }

  @GetMapping(value = "/getBrsProvidedSources")
  public List<Source> getBrsProvidedSources() {
    return closerDashboardService.getBrsProvidedSources();
  }

  @GetMapping(value = "/getSelfGenSources")
  public List<Source> getSelfGenSources() {
    return closerDashboardService.getSelfGenSources();
  }

  @PostMapping(value = "/funnel/apptsCreatedPipeline")
  public String apptsCreatedPipeline(@RequestBody FunnelRequest funnelRequest) {
    return closerDashboardService.apptsCreatedPipeline(funnelRequest);
  }

    @PostMapping(value = "/funnelDrilldown/apptsCreatedPipeline")
  public String apptsCreatedPipelineDrilldown(@RequestBody FunnelRequest funnelRequest) {
    return closerDashboardService.apptsCreatedPipelineDrilldown(funnelRequest);
  }

  @PostMapping(value = "/getAreas")
  public String getAreas(@RequestBody DashboardUserRequest request) {
    return closerDashboardService.getAreas(request);
  }

  @PostMapping(value = "/getRegions")
  public String getRegions(@RequestBody DashboardUserRequest request) {
    return closerDashboardService.getRegions(request);
  }

  @PostMapping(value = "/getDistricts")
  public String Districts(@RequestBody DashboardUserRequest request) {
    return closerDashboardService.getDistricts(request);
  }

  @PostMapping(value = "/getOffices")
  public String getOffices(@RequestBody DashboardUserRequest request) {
    return closerDashboardService.getOffices(request);
  }

  @PostMapping(value = "/getReps")
  public String getReps(@RequestBody DashboardUserRequest request) {
    return closerDashboardService.getReps(request);
  }

  @PostMapping(value = "/funnel/standard")
  public String funnelStandard(@RequestBody FunnelRequest funnelRequest) {
    return closerDashboardService.funnelStandard(funnelRequest);
  }

  @PostMapping(value = "/funnelDrilldown/standard")
  public String funnelDrilldownStandard(@RequestBody FunnelRequest funnelRequest) {
    return closerDashboardService.funnelDrilldownStandard(funnelRequest);
  }

  @PostMapping(value = "/funnel/apptDateCohort")
  public String funnelApptDateCohort(@RequestBody FunnelRequest funnelRequest) {
    return closerDashboardService.funnelApptDateCohort(funnelRequest);
  }

  @PostMapping(value = "/funnelDrilldown/apptDateCohort")
  public String funnelDrilldownApptDateCohort(@RequestBody FunnelRequest funnelRequest) {
    return closerDashboardService.funnelDrilldownApptDateCohort(funnelRequest);
  }
}
