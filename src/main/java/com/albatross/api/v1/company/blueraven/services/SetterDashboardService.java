package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.IronmanCounts;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;

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

  public IronmanCounts getIronmanPitchCounts(Boolean isSetterMgr, Integer setterMgrOfficeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("isSetterMgr", isSetterMgr);
    params.put("setterMgrOfficeId", setterMgrOfficeId);

    return sqlCache.query("setterDashboard.getIronmanPitchCounts", params, IronmanCounts.class).get(0);
  }

  public String pitchesDrilldown(int quarter, Boolean isSetterMgr, Integer setterMgrOfficeId) {
    String sqlQuery = "SELECT * FROM brs.get_pitches_drilldown(:userId::INTEGER, :quarter::INTEGER, :isSetterMgr::BOOLEAN, :setterMgrOfficeId::INTEGER)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("quarter", quarter);
    parameters.addValue("isSetterMgr", isSetterMgr);
    parameters.addValue("setterMgrOfficeId", setterMgrOfficeId);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getPerformanceReport(String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_performance_report(:currentUserId::integer, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("currentUserId", securityService.getCurrentUser().getId());
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getMgrPerformanceReport(Integer officeId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_mgr_performance_report(:officeId::integer, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("officeId", officeId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String repToBeat(int userId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_to_beat(:userId::integer, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String updated = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return updated;
  }

  public String officeToBeat(int officeId, String startDate, String endDate) {
    String sqlQuery = "SELECT * FROM brs.get_setter_office_to_beat(:officeId::integer, :startDate::date, :endDate::date)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("officeId", officeId);
    parameters.addValue("startDate", startDate);
    parameters.addValue("endDate", endDate);

    String updated = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return updated;
  }

  public String topReps(int limit, int days) {
    String sqlQuery = "SELECT * FROM brs.get_top_setter_reps(:limit, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);

    String updated = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return updated;
  }

  public String topOffices(int limit, int days) {
    String sqlQuery = "SELECT * FROM brs.get_top_setter_offices(:limit, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);

    String updated = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return updated;
  }

  public String officeRanking(int limit, int days) {
    String sqlQuery = "SELECT * FROM brs.get_setter_office_ranking(:limit, :days)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("limit", limit);
    parameters.addValue("days", days);

    String updated = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return updated;
  }
}
