package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.company.blueraven.models.CloserTableScores;
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

import java.math.BigInteger;
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
  @Value("${aws.storageBucket}")
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

    List<Long> userIds = new ArrayList<>();
    for (Object row : closerDashboardData.getJSONArray("officeRankingValues")) {
      JSONObject rowObject = (JSONObject)row;
      userIds.add(rowObject.getLong("userId"));
    }

    for (Object row : closerDashboardData.getJSONArray("companyRankingValues")) {
      JSONObject rowObject = (JSONObject)row;
      userIds.add(rowObject.getLong("userId"));
    }

    Map<Long, String> userImageUrls = attachmentService.getAttachmentPresignedUrlForUserList(bucket, userIds, 9L);

    for (Object row : closerDashboardData.getJSONArray("officeRankingValues")) {
      JSONObject rowObject = (JSONObject)row;

      if (userImageUrls.get(rowObject.getLong("userId")) != null) {
        rowObject.put("userImageUrl", userImageUrls.get(rowObject.getLong("userId")));
        rowObject.put("userImageAltText", "Photo of " + rowObject.get("name") + ", a Blue Raven Solar employee");
      } else {
        rowObject.put("userImageUrl", "../../assets/user_img_placeholder.png");
        rowObject.put("userImageAltText", "User image placeholder");
      }
    }

    for (Object row : closerDashboardData.getJSONArray("companyRankingValues")) {
      JSONObject rowObject = (JSONObject)row;

      if (userImageUrls.get(rowObject.getLong("userId")) != null) {
        rowObject.put("userImageUrl", userImageUrls.get(rowObject.getLong("userId")));
        rowObject.put("userImageAltText", "Photo of " + rowObject.get("name") + ", a Blue Raven Solar employee");
      } else {
        rowObject.put("userImageUrl", "../../assets/user_img_placeholder.png");
        rowObject.put("userImageAltText", "User image placeholder");
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
        closerTableScoresJson.put("companyName", row.getCompanyName());
        closerTableScoresJson.put("region", row.getRegion());
        closerTableScoresJson.put("salesMetroArea", row.getSalesMetroArea());

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
}
