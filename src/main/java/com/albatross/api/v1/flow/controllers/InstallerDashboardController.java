package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.InstallerDashboardService;
import com.albatross.api.v1.flow.services.WorkQueueService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Created by John Berns on 2021-05-05.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/installerDashboard")
public class InstallerDashboardController {

  @Autowired
  private InstallerDashboardService installerDashboardService;

  @Autowired
  WorkQueueService workQueueService;

  @GetMapping(value = "/owners", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueOwner> getWorkQueueOwners (@RequestBody Map<String, String> requestData) {
    return installerDashboardService.getOwners(requestData.get("startDate"), requestData.get("endDate"), requestData.get("installationCrewId"));
  }

  @GetMapping(value = "/regionalManagers", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Owner> getRegionalManagers() {
    return installerDashboardService.getRegionalManagers();
  }

  @GetMapping(value = "/installationCrew/{regionalManagerId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Owner> getInstallationCrew(@PathVariable Long regionalManagerId) {
    return installerDashboardService.getInstallationCrew(regionalManagerId);
  }

  @GetMapping(value = "/dashboardValues")
  public String getDashboardValues(@RequestParam String startDate,
                                   @RequestParam String endDate,
                                   @RequestParam Long installationCrewId) {
    return installerDashboardService.getDashboardValues(startDate, endDate, installationCrewId);
  }

  @GetMapping(value = "/wipValues")
  public List<WorkQueue> getWipValues() {
    return installerDashboardService.getWorkQueues();
  }

  @GetMapping(value = "/performanceMetrics")
  public String getPerformanceMetrics(@RequestParam String startDate,
                                   @RequestParam String endDate) {
    return installerDashboardService.getPerformanceMetrics(startDate, endDate);
  }
}
