package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.WorkQueue;
import com.albatross.api.v1.flow.model.WorkQueueOwner;
import com.albatross.api.v1.company.blueraven.services.InstallerDashboardService;
import com.albatross.api.v1.flow.services.WorkQueueService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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

  @GetMapping(value = "/installationCrew/{regionalManagerIds}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Owner> getInstallationCrew(@PathVariable List<Long> regionalManagerIds) {
    return installerDashboardService.getInstallationCrew(regionalManagerIds);
  }

  @GetMapping(value = "/dashboardValues/{installationCrewIds}")
  public String getDashboardValues(@PathVariable List<Long> installationCrewIds,
                                   @RequestParam String startDate,
                                   @RequestParam String endDate) {
    return installerDashboardService.getDashboardValues(startDate, endDate, installationCrewIds);
  }

  @GetMapping(value = "/wipValues")
  public List<WorkQueue> getWipValues() {
    return installerDashboardService.getWorkQueues();
  }

  @GetMapping(value = "/wipValues/{installationCrewIds}")
  public List<WorkQueue> getWipValues(@PathVariable List<Long> installationCrewIds) {
    return installerDashboardService.getWorkQueues(installationCrewIds);
  }

  @GetMapping(value = "/performanceMetrics")
  public String getPerformanceMetrics(@RequestParam String startDate,
                                   @RequestParam String endDate) {
    return installerDashboardService.getPerformanceMetrics(startDate, endDate);
  }
}
