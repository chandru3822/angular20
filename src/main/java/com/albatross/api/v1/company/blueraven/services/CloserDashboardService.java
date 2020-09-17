package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.company.blueraven.models.CloserTableScores;
import com.albatross.api.v1.company.blueraven.models.DashboardUserRequest;
import com.albatross.api.v1.company.blueraven.models.IronmanCounts;
import com.albatross.api.v1.flow.services.AttachmentService;
import com.albatross.api.security.SecurityService;

import com.albatross.api.utils.SqlCache;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Joseph Canto on 2020-04-30.
 */
@Service
public class CloserDashboardService {
//  @Value("${aws.blueraven.storageBucket}") // TODO: Replace this after user photos have been migrated to new AWS s3 storage
  @Value("blueraven-photos")
  private String bucket;

  @Autowired
  private AttachmentService attachmentService;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private SqlCache sqlCache;

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

  public String getCloserTableScores(int timeInterval) {
    JSONObject closerDashboardData = new JSONObject();
    closerDashboardData.put("officeRankingValues", processCloserData(timeInterval, true));
    closerDashboardData.put("companyRankingValues", processCloserData(timeInterval, false));

    return getUserImages(new String[] {"officeRankingValues", "companyRankingValues"}, closerDashboardData);
  }

  public String getUserImages(String[] keys, JSONObject closerDashboardData) {
    List<Long> userIds = new ArrayList<>();

    for (String key : keys) {
      for (Object row : closerDashboardData.getJSONArray(key)) {
        JSONObject rowObject = (JSONObject)row;
        userIds.add(rowObject.getLong("userId"));
      }
    }

    Map<Long, String> userImageUrls = attachmentService.getAttachmentPresignedUrlForUserList(bucket, userIds, 9L);

    for (String key : keys) {
      for (Object row : closerDashboardData.getJSONArray(key)) {
        JSONObject rowObject = (JSONObject)row;

        if (userImageUrls.get(rowObject.getLong("userId")) != null) {
          rowObject.put("userImageUrl", userImageUrls.get(rowObject.getLong("userId")));
          rowObject.put("userImageAltText", "Photo of " + rowObject.get("name") + ", a Blue Raven Solar employee");
        } else {
          rowObject.put("userImageAltText", "User photo placeholder");
        }
      }
    }

    return closerDashboardData.toString();
  }

  private JSONArray processCloserData(Integer timeInterval, boolean officeRanking) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("timeInterval", timeInterval);
    params.put("officeRanking", officeRanking);

    List<CloserTableScores> closerTableScores = sqlCache.query("closerDashboard.getCloserTableScores", params, CloserTableScores.class);

    JSONArray closerTableScoresArray = new JSONArray();
    for (CloserTableScores row : closerTableScores) {
      try {
        JSONObject closerTableScoresJson = new JSONObject();
        closerTableScoresJson.put("userId", row.getId());
        closerTableScoresJson.put("name", row.getName());
        closerTableScoresJson.put("userStatusType", row.getUserStatusType());
        closerTableScoresJson.put("officeName", row.getOfficeName());
        closerTableScoresJson.put("region", row.getRegion());
        closerTableScoresJson.put("metroArea", row.getMetroArea());

        double leadGenFdcValue = 0;
        if (row.getLeadGenFdcPercentageDenominator() != 0) {
          leadGenFdcValue = ((double)row.getLeadGenFdcPercentageNumerator() / row.getLeadGenFdcPercentageDenominator());
        }
        closerTableScoresJson.put("leadGenFdcPercentage", new DecimalFormat("#.#").format(leadGenFdcValue * 100));

        closerTableScoresJson.put("selfGenFdc", row.getSelfGenFdc());
        closerTableScoresJson.put("totalFdc", row.getTotalFdc());

        closerTableScoresArray.put(closerTableScoresJson);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    return closerTableScoresArray;
  }

  public String getDistricts(int userId, Boolean setterOverride) {
    String sqlQuery = "SELECT * FROM flow.util_closer_district_selection(:userId, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("setterOverride", setterOverride);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getRegions(int userId, String districts, Boolean setterOverride) {
    districts = districts.replace("%5B", "[").replace("%7B", "{").replace("%7D", "}").replace("%22", "\"").replace("%5D", "]");

    String sqlQuery = "SELECT * FROM flow.util_closer_region_selection(:userId, :districts::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("districts", districts);
    parameters.addValue("setterOverride", setterOverride);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getOffices(int userId, String regions, Boolean setterOverride) {
    regions = regions.replace("%5B", "[").replace("%7B", "{").replace("%7D", "}").replace("%22", "\"").replace("%5D", "]");

    String sqlQuery = "SELECT * FROM flow.util_closer_office_selection(:userId, :regions::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("regions", regions);
    parameters.addValue("setterOverride", setterOverride);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getReps(DashboardUserRequest req) {
    String sqlQuery = "SELECT * FROM flow.util_closer_rep_selection(:userId::int, :regions::JSON, :offices::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("regions", req.getRegions());
    parameters.addValue("offices", req.getOffices());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }
}
