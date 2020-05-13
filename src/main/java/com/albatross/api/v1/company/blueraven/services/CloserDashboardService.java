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
 * Created by Joseph Canto on 2020-04-30.
 */
@Service
public class CloserDashboardService {
  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private NamedParameterJdbcTemplate jdbc;

  public IronmanCounts getIronmanFdcCounts() {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());

    return sqlCache.query("closerDashboard.getIronmanFdcCounts", params, IronmanCounts.class).get(0);
  }

  public String finalDesignsCompletedDrilldown(int quarter) {
    String sqlQuery = "SELECT * FROM brs.get_final_designs_completed_drilldown(:userId::INTEGER, :quarter::INTEGER)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("quarter", quarter);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }
}
