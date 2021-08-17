package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ProcessStepStatusType;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.WorkQueue;
import com.albatross.api.v1.flow.model.WorkQueueOwner;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;


/**
 * Created by John Berns on 2021-05-05.
 * !Describe Purpose!
 */
@Slf4j
@Service
public class InstallerDashboardService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  @Autowired
  NamedParameterJdbcTemplate jdbc;

  public List<WorkQueueOwner> getOwners(String startDate, String endDate, String installationCrewId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("installationCrewId", installationCrewId);

    List<WorkQueueOwner> results = sqlCache.query("workQueue.getWorkQueueOwners", params, WorkQueueOwner.class);
    return results;
  }

  public List<Owner> getRegionalManagers() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());

    List<Owner> results = sqlCache.query("installerDashboard.getRegionalManagers", params, Owner.class);
    return results;
  }

  public List<Owner> getInstallationCrew(List<Long> regionalManagerIds) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("orgIds", regionalManagerIds);

    List<Owner> results = sqlCache.query("installerDashboard.getInstallationCrew", params, Owner.class);
    return results;
  }


  public String getDashboardValues(String startDate, String endDate, List<Long> installationCrewIds) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("companyId", user.getCompanyId());
    params.put("crewIds", installationCrewIds);

    String results = sqlCache.queryForObject("installerDashboard.getDashboardValues", params, String.class);
    JSONObject jsonResults = new JSONObject(results);
    JSONArray tiles = new JSONArray();

    JSONObject substantialCompletionsTile = new JSONObject();
    substantialCompletionsTile.put("name", "Substantial Completions");
    substantialCompletionsTile.put("value", jsonResults.getDouble("substantialCompletions"));
    substantialCompletionsTile.put("drilldownData", jsonResults.getJSONArray("substantialCompletionsDrilldown"));

    JSONObject sameWeekCloseoutTile = new JSONObject();
    sameWeekCloseoutTile.put("name", "Same-week Closeout %");
    sameWeekCloseoutTile.put("value", Math.round(jsonResults.getDouble("sameWeekCloseout") * 100) + "%");
    sameWeekCloseoutTile.put("drilldownData", jsonResults.getJSONArray("sameWeekCloseoutDrilldown"));

    JSONObject onTimeCloseoutTile = new JSONObject();
    onTimeCloseoutTile.put("name", "On-time Closeout %");
    onTimeCloseoutTile.put("value", Math.round(jsonResults.getDouble("onTimeCloseout") * 100) + "%");
    onTimeCloseoutTile.put("drilldownData", jsonResults.getJSONArray("onTimeCloseoutDrilldown"));

    JSONObject inspectionApprovalTile = new JSONObject();
    inspectionApprovalTile.put("name", "Inspection Pass Rate");
    inspectionApprovalTile.put("value", Math.round(jsonResults.getDouble("inspectionApproval") * 100) + "%");
    inspectionApprovalTile.put("drilldownData", jsonResults.getJSONArray("inspectionApprovalDrilldown"));

    tiles.put(substantialCompletionsTile);
    tiles.put(sameWeekCloseoutTile);
    tiles.put(onTimeCloseoutTile);
    tiles.put(inspectionApprovalTile);
    return tiles.toString();
  }

  public String getPerformanceMetrics(String startDate, String endDate) {
    User user = securityService.getCurrentUser();

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("parentCompanyId", user.getHighestParentCompanyId());
    parameters.addValue("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    parameters.addValue("companyId", user.getCompanyId());
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);
    return jdbc.queryForObject(sqlCache.getByKey("installerDashboard.getPerformanceMetrics"), parameters, String.class);
  }

  public List<WorkQueue> getWorkQueues() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueCategoryId", null);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userPositionId", null);
    params.put("unassigned", false);
    //currently we only show active process steps. but sending in as a list in case that changes
    params.put("processStepStatusTypeIds", new ArrayList<>(Arrays.asList(ProcessStepStatusType.ACTIVE.id)));

    List<WorkQueue> results = sqlCache.query("workQueue.getInstallerDashboardWorkQueues", params, WorkQueue.class);
    return results;
  }

  public List<WorkQueue> getWorkQueues(List<Long> installationCrewIds) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueCategoryId", null);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userPositionId", null);
    params.put("unassigned", false);
    //currently we only show active process steps. but sending in as a list in case that changes
    params.put("processStepStatusTypeIds", new ArrayList<>(Arrays.asList(ProcessStepStatusType.ACTIVE.id)));
    params.put("crewIds", installationCrewIds);

    List<WorkQueue> results = sqlCache.query("workQueue.getInstallerDashboardWorkQueues", params, WorkQueue.class);
    return results;
  }
}
