package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.DashboardUserRequest;
import com.albatross.api.v1.company.blueraven.models.FunnelRequest;
import com.albatross.api.v1.company.blueraven.models.IncentiveCounts;
import com.albatross.api.v1.company.blueraven.services.queries.SetterDashboardQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Joseph Canto on 2020-07-06.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@PreAuthorize("(hasCompanyAccess(3) || hasCompanyAccess(18)) && hasFeatureAccess('SETTER_DASHBOARD')")
public class SetterDashboardService {

  private final SecurityService securityService;
  private final SqlCache sqlCache;

  public IncentiveCounts getIncentivePitchCounts(Boolean isSetterMgr, Integer setterMgrOfficeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("isSetterMgr", isSetterMgr);
    params.put("setterMgrOfficeId", setterMgrOfficeId);

    IncentiveCounts incentiveCounts = sqlCache.queryBySql(SetterDashboardQuery.getIncentivePitchCounts, params, IncentiveCounts.class).get(0);
    return incentiveCounts;
  }

  public String pitchesDrilldown(int quarter, Boolean isSetterMgr, Integer setterMgrOfficeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", securityService.getCurrentUser().getId());
    params.put("quarter", quarter);
    params.put("isSetterMgr", isSetterMgr);
    params.put("setterMgrOfficeId", setterMgrOfficeId);

    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.pitchesDrilldown, params, String.class);
    return result;
  }

  public String getPerformanceReport(String startDate, String endDate) {
    Map<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.getPerformanceReport, params, String.class);
    return result;
  }

  public String getMgrPerformanceReport(Integer officeId, String startDate, String endDate) {
    Map<String, Object> params = new HashMap<>();
    params.put("officeId", officeId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.getMgrPerformanceReport, params, String.class);
    return result;
  }

  public String repToBeat(int userId, String startDate, String endDate) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.repToBeat, params, String.class);
    return result;
  }

  public String officeToBeat(int officeId, String startDate, String endDate) {
    Map<String, Object> params = new HashMap<>();
    params.put("officeId", officeId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.officeToBeat, params, String.class);
    return result;
  }

  public String topReps(int limit, int days, String interval) {
    Map<String, Object> params = new HashMap<>();
    params.put("limit", limit);
    params.put("days", days);
    params.put("interval", interval);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.topReps, params, String.class);
    return result;
  }

  public String topOffices(int limit, int days, String interval) {
    Map<String, Object> params = new HashMap<>();
    params.put("limit", limit);
    params.put("days", days);
    params.put("interval", interval);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.topOffices, params, String.class);
    return result;
  }

  public String officeRanking(int limit, int days, String interval) {
    Map<String, Object> params = new HashMap<>();
    params.put("limit", limit);
    params.put("days", days);
    params.put("interval", interval);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.officeRanking, params, String.class);
    return result;
  }

  public String getAreas(DashboardUserRequest req) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", req.getUserId());

    String results = sqlCache.queryForObjectBySql(SetterDashboardQuery.getAreas, params, String.class);
    return null == results ? "[]" : results;
  }

  public String getRegions(DashboardUserRequest req) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", req.getUserId());
    params.put("areas", req.getAreas());

    String results = sqlCache.queryForObjectBySql(SetterDashboardQuery.getRegions, params, String.class);
    return null == results ? "[]" : results;
  }

  public String getDistricts(DashboardUserRequest req) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", req.getUserId());
    params.put("areas", req.getAreas());
    params.put("regions", req.getRegions());

    String results = sqlCache.queryForObjectBySql(SetterDashboardQuery.getDistricts, params, String.class);
    return null == results ? "[]" : results;
  }

  public String getOffices(DashboardUserRequest req) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", req.getUserId());
    params.put("areas", req.getAreas());
    params.put("regions", req.getRegions());
    params.put("districts", req.getDistricts());

    String results = sqlCache.queryForObjectBySql(SetterDashboardQuery.getOffices, params, String.class);
    return null == results ? "[]" : results;
  }

  public String getReps(DashboardUserRequest req) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", req.getUserId());
    params.put("areas", req.getAreas());
    params.put("regions", req.getRegions());
    params.put("districts", req.getDistricts());
    params.put("offices", req.getOffices());

    String results = sqlCache.queryForObjectBySql(SetterDashboardQuery.getReps, params, String.class);
    return null == results ? "[]" : results;
  }

  public String loadFunnel(FunnelRequest funnelRequest) {
    Map<String, Object> params = new HashMap<>();
    params.put("startDate", funnelRequest.getStart());
    params.put("endDate", funnelRequest.getEnd());
    params.put("userIds", funnelRequest.getUsers());
    params.put("orgIds", funnelRequest.getOrgs());
    params.put("isCohort", null != funnelRequest.getIsCohort() ? funnelRequest.getIsCohort() : false);

    return sqlCache.queryForObjectBySql(SetterDashboardQuery.loadFunnel, params, String.class);
  }

  public String funnelDrilldown(FunnelRequest funnelRequest) {
    Map<String, Object> params = new HashMap<>();
    params.put("startDate", funnelRequest.getStart());
    params.put("endDate", funnelRequest.getEnd());
    params.put("funnelId", funnelRequest.getFunnelId());
    params.put("userIds", funnelRequest.getUsers());
    params.put("orgIds", funnelRequest.getOrgs());
    params.put("isCohort", null != funnelRequest.getIsCohort() ? funnelRequest.getIsCohort() : false);

    return sqlCache.queryForObjectBySql(SetterDashboardQuery.loadFunnelDrilldown, params, String.class);
  }
}
