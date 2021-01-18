package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.DashboardUserRequest;
import com.albatross.api.v1.company.blueraven.models.FunnelRequest;
import com.albatross.api.v1.company.blueraven.models.IncentiveCounts;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-07-06.
 */
@Service
public class SetterDashboardService {
  @Autowired
  private SecurityService securityService;

  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private NamedParameterJdbcTemplate jdbc;

  public IncentiveCounts getIncentivePitchCounts(Boolean isSetterMgr, Integer setterMgrOfficeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("isSetterMgr", isSetterMgr);
    params.put("setterMgrOfficeId", setterMgrOfficeId);

    IncentiveCounts incentiveCounts = sqlCache.query("setterDashboard.getIncentivePitchCounts", params, IncentiveCounts.class).get(0);
    return incentiveCounts;
  }

  public String pitchesDrilldown(int quarter, Boolean isSetterMgr, Integer setterMgrOfficeId) {
    String sqlQuery = "SELECT * FROM brs.get_pitches_drilldown(:userId::INTEGER, :quarter::INTEGER, :isSetterMgr::BOOLEAN, :setterMgrOfficeId::INTEGER)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("quarter", quarter);
    parameters.addValue("isSetterMgr", isSetterMgr);
    parameters.addValue("setterMgrOfficeId", setterMgrOfficeId);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String getPerformanceReport(String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_performance_report(:currentUserId::integer, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("currentUserId", securityService.getCurrentUser().getId());
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String getMgrPerformanceReport(Integer officeId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_mgr_performance_report(:officeId::integer, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("officeId", officeId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String repToBeat(int userId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_to_beat(:userId::integer, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String officeToBeat(int officeId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_office_to_beat(:officeId::integer, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("officeId", officeId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String topReps(int limit, int days) {
    String sqlQuery = "SELECT * FROM brs.get_top_setter_reps(:limit, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String topOffices(int limit, int days) {
    String sqlQuery = "SELECT * FROM brs.get_top_setter_offices(:limit, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String officeRanking(int limit, int days) {
    String sqlQuery = "SELECT * FROM brs.get_setter_office_ranking(:limit, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String getDistricts(int userId) {
    String sqlQuery = "SELECT * FROM brs.util_setter_district_selection(:userId)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getRegions(int userId, String districts) {
    districts = districts.replace("%5B", "[").replace("%7B", "{").replace("%7D", "}").replace("%22", "\"").replace("%5D", "]");

    String sqlQuery = "SELECT * FROM brs.util_setter_region_selection(:userId, :districts::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("districts", districts);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getOffices(int userId, String regions) {
    regions = regions.replace("%5B", "[").replace("%7B", "{").replace("%7D", "}").replace("%22", "\"").replace("%5D", "]");

    String sqlQuery = "SELECT * FROM brs.util_setter_office_selection(:userId, :regions::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("regions", regions);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getReps(DashboardUserRequest req) {
    String sqlQuery = "SELECT * FROM brs.util_setter_rep_selection(:userId::int, :regions::JSON, :offices::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("regions", req.getRegions());
    parameters.addValue("offices", req.getOffices());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String funnelStandard(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_setter_funnel_standard(:startDate::date, :endDate::date, :target::numeric, array[ :userIds ]::integer[], array[ :orgIds ]::integer[])";

    return runFunnelQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getTargetInstallations(), funnelRequest.getUsers(), funnelRequest.getOrgs());
  }

  public String funnelCohort(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_setter_funnel_cohort(:startDate::date, :endDate::date, :target::numeric, array[ :userIds ]::integer[], array[ :orgIds ]::integer[])";

    return runFunnelQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getTargetInstallations(), funnelRequest.getUsers(), funnelRequest.getOrgs());
  }

  private String runFunnelQuery(String sqlQuery, String start, String end, BigDecimal target, List<Long> userIds, List<Long> orgIds) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", start);
    parameters.addValue("endDate", end);
    parameters.addValue("target", target);
    parameters.addValue("userIds", userIds);
    parameters.addValue("orgIds", orgIds);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String funnelDrilldownStandard(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_setter_funnel_standard_drilldown(:startDate::date, :endDate::date, :funnelId, array[ :userIds ]::integer[], array[ :orgIds ]::integer[])";

    return runFunnelDrilldownQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getFunnelId(), funnelRequest.getUsers(), funnelRequest.getOrgs());
  }

  public String funnelDrilldownCohort(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_setter_funnel_cohort_drilldown(:startDate::date, :endDate::date, :funnelId, array[ :userIds ]::integer[], array[ :orgIds ]::integer[])";

    return runFunnelDrilldownQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getFunnelId(), funnelRequest.getUsers(), funnelRequest.getOrgs());
  }

  private String runFunnelDrilldownQuery(String sqlQuery, String start, String end, int funnelId, List<Long> userIds, List<Long> orgIds) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", start);
    parameters.addValue("endDate", end);
    parameters.addValue("funnelId", funnelId);
    parameters.addValue("userIds", userIds);
    parameters.addValue("orgIds", orgIds);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }
}
