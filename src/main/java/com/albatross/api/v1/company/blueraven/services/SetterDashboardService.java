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
    String sqlQuery = "SELECT * FROM brs.get_pitches_drilldown(:userId::bigint, :quarter::bigint, :isSetterMgr::BOOLEAN, :setterMgrOfficeId::bigint)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("quarter", quarter);
    parameters.addValue("isSetterMgr", isSetterMgr);
    parameters.addValue("setterMgrOfficeId", setterMgrOfficeId);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String getPerformanceReport(String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_performance_report(:currentUserId::bigint, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("currentUserId", securityService.getCurrentUser().getId());
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String getMgrPerformanceReport(Integer officeId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_mgr_performance_report(:officeId::bigint, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("officeId", officeId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String repToBeat(int userId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_to_beat(:userId::bigint, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String officeToBeat(int officeId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_office_to_beat(:officeId::bigint, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("officeId", officeId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String topReps(int limit, int days, String interval) {
    String sqlQuery = "SELECT * FROM brs.get_top_setter_reps(:limit, :interval, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);
    parameters.addValue("interval", interval);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String topOffices(int limit, int days, String interval) {
    String sqlQuery = "SELECT * FROM brs.get_top_setter_offices(:limit, :interval, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);
    parameters.addValue("interval", interval);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String officeRanking(int limit, int days, String interval) {
    String sqlQuery = "SELECT * FROM brs.get_setter_office_ranking(:limit, :interval, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);
    parameters.addValue("interval", interval);

    String result = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return result;
  }

  public String getAreas(DashboardUserRequest req) {
    String sqlQuery = "SELECT * FROM brs.util_setter_area_selection(:userId::bigint)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getRegions(DashboardUserRequest req) {
    String sqlQuery = "SELECT * FROM brs.util_setter_region_selection(:userId::bigint, :areas::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("areas", req.getAreas());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getDistricts(DashboardUserRequest req) {
    String sqlQuery = "SELECT * FROM brs.util_setter_district_selection(:userId::bigint, :areas::JSON, :regions::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("areas", req.getAreas());
    parameters.addValue("regions", req.getRegions());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getOffices(DashboardUserRequest req) {
    String sqlQuery = "SELECT * FROM brs.util_setter_office_selection(:userId::bigint, :areas::JSON, :regions::JSON, :districts::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("areas", req.getAreas());
    parameters.addValue("regions", req.getRegions());
    parameters.addValue("districts", req.getDistricts());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getReps(DashboardUserRequest req) {
    String sqlQuery = "SELECT * FROM brs.util_setter_rep_selection(:userId::bigint, :areas::JSON, :regions::JSON, :districts::JSON, :offices::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("areas", req.getAreas());
    parameters.addValue("regions", req.getRegions());
    parameters.addValue("districts", req.getDistricts());
    parameters.addValue("offices", req.getOffices());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String funnelStandard(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_setter_funnel_standard(:startDate::date, :endDate::date, :target::numeric, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], false)";

    return runFunnelQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getTargetInstallations(), funnelRequest.getUsers(), funnelRequest.getOrgs());
  }

  public String funnelCohort(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_setter_funnel_standard(:startDate::date, :endDate::date, :target::numeric, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], true)";

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
//    String sqlQuery = "select brs.rpt_setter_funnel_standard_drilldown(:startDate::date, :endDate::date, :funnelId, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[])";
    String sqlQuery = "select brs.rpt_setter_funnel_standard_and_cohort_drilldown(:startDate::date, :endDate::date, :funnelId, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[])";

    return runFunnelDrilldownQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getFunnelId(), funnelRequest.getUsers(), funnelRequest.getOrgs());
  }

  public String funnelDrilldownCohort(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_setter_funnel_standard_and_cohort_drilldown(:startDate::date, :endDate::date, :funnelId, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[])";

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
