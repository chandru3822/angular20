package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.InstallerDashboardQuery;
import com.albatross.api.v1.flow.enums.ProcessStepStatusType;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.workQueue.WorkQueue;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueOwner;
import com.albatross.api.v1.flow.queries.WorkQueueQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccess('INSTALLER_DASHBOARD')")
@RequiredArgsConstructor
public class InstallerDashboardService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final NamedParameterJdbcTemplate jdbc;

  public List<WorkQueueOwner> getOwners(
      String startDate, String endDate, String installationCrewId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("installationCrewId", installationCrewId);

    return sqlCache.queryBySql(WorkQueueQuery.getWorkQueueOwners, params, WorkQueueOwner.class);
  }

  public List<Owner> getRegionalManagers() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());

    return sqlCache.queryBySql(InstallerDashboardQuery.getRegionalManagers, params, Owner.class);
  }

  public List<Owner> getInstallationCrew(List<Long> regionalManagerIds) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("orgIds", regionalManagerIds);

    return sqlCache.queryBySql(InstallerDashboardQuery.getInstallationCrew, params, Owner.class);
  }

  public String getDashboardValues(
      String startDate, String endDate, List<Long> installationCrewIds) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("companyId", user.getCompanyId());
    params.put("crewIds", installationCrewIds);

    String results =
        sqlCache.queryForObjectBySql(InstallerDashboardQuery.getDashboardValues, params, String.class);
    JSONObject jsonResults = new JSONObject(results);
    JSONArray tiles = new JSONArray();

    JSONObject substantialCompletionsTile = new JSONObject();
    substantialCompletionsTile.put("name", "Substantial Completions");
    substantialCompletionsTile.put("value", jsonResults.getDouble("substantialCompletions"));
    substantialCompletionsTile.put(
        "drilldownData", jsonResults.getJSONArray("substantialCompletionsDrilldown"));

    JSONObject sameWeekCloseoutTile = new JSONObject();
    sameWeekCloseoutTile.put("name", "Same-week Closeout %");
    sameWeekCloseoutTile.put(
        "value", Math.round(jsonResults.getDouble("sameWeekCloseout") * 100) + "%");
    sameWeekCloseoutTile.put(
        "drilldownData", jsonResults.getJSONArray("sameWeekCloseoutDrilldown"));

    JSONObject onTimeCloseoutTile = new JSONObject();
    onTimeCloseoutTile.put("name", "On-time Closeout %");
    onTimeCloseoutTile.put(
        "value", Math.round(jsonResults.getDouble("onTimeCloseout") * 100) + "%");
    onTimeCloseoutTile.put("drilldownData", jsonResults.getJSONArray("onTimeCloseoutDrilldown"));

    JSONObject inspectionApprovalTile = new JSONObject();
    inspectionApprovalTile.put("name", "Inspection Pass Rate");
    inspectionApprovalTile.put(
        "value", Math.round(jsonResults.getDouble("inspectionApproval") * 100) + "%");
    inspectionApprovalTile.put(
        "drilldownData", jsonResults.getJSONArray("inspectionApprovalDrilldown"));

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
    parameters.addValue("currentUserId", securityService.getCurrentUser().trueUserId());
    return jdbc.queryForObject(
        InstallerDashboardQuery.getPerformanceMetrics, parameters, String.class);
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
    // currently we only show active process steps. but sending in as a list in case that changes
    params.put("processStepStatusTypeIds", List.of(ProcessStepStatusType.ACTIVE.id));

    return sqlCache.queryBySql(WorkQueueQuery.getInstallerDashboardWorkQueues, params, WorkQueue.class);
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
    // currently we only show active process steps. but sending in as a list in case that changes
    params.put("processStepStatusTypeIds", List.of(ProcessStepStatusType.ACTIVE.id));
    params.put("crewIds", installationCrewIds);

    return sqlCache.queryBySql(WorkQueueQuery.getInstallerDashboardWorkQueues, params, WorkQueue.class);
  }
}
