package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.flow.model.PostalCodeZone;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.AttachmentService;
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

  public List<PostalCodeZone> getRoundRobins() {
    User user = securityService.getCurrentUser();
    Boolean viewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "CLOSER_DASHBOARD", List.of("VIEW_ALL"));

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("viewAll", viewAll);
    params.put("companyId", user.getCompanyId());

    String sqlKey = viewAll ? "closerDashboard.getAllRoundRobins" : "closerDashboard.getRoundRobins";

    return sqlCache.query(sqlKey, params, PostalCodeZone.class);
  }

  public List<OfficeLeadAllocationScores> getOfficeLeadAllocationRank(Integer postalCodeZoneId, Integer timeInterval) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCodeZoneId", postalCodeZoneId);
    params.put("timeInterval", timeInterval);

    List<OfficeLeadAllocationScores> officeLeadAllocationData = sqlCache.query("closerDashboard.getOfficeLeadAllocationRank", params, OfficeLeadAllocationScores.class);
    List<Long> userIds = new ArrayList<>();

    for (OfficeLeadAllocationScores row : officeLeadAllocationData) {
      userIds.add(row.getUserId());
    }

    Map<Long, String> userImageUrls = getUserImages(userIds);

    for (OfficeLeadAllocationScores row : officeLeadAllocationData) {
      if (userImageUrls.get(row.getUserId()) != null) {
        row.setUserImageUrl(userImageUrls.get(row.getUserId()));
        row.setUserImageAltText("Photo of " + row.getCloserName() + ", a Blue Raven Solar employee");
      } else {
        row.setUserImageAltText("User photo placeholder");
      }
    }

    return officeLeadAllocationData;
  }

  public String getCloserTableScores(int timeInterval) {
    JSONObject closerDashboardData = new JSONObject();
    closerDashboardData.put("officeFdcRankValues", processCloserData(timeInterval, true));
    closerDashboardData.put("companyRankingValues", processCloserData(timeInterval, false));

    return getUserImages(new String[] {"officeFdcRankValues", "companyRankingValues"}, closerDashboardData);
  }

  public Map<Long, String> getUserImages(List<Long> userIds) {
    return attachmentService.getAttachmentPresignedUrlsForUserList(userIds, 9L);
  }

  public String getUserImages(String[] keys, JSONObject closerDashboardData) {
    List<Long> userIds = new ArrayList<>();

    for (String key : keys) {
      for (Object row : closerDashboardData.getJSONArray(key)) {
        JSONObject rowObject = (JSONObject)row;
        userIds.add(rowObject.getLong("userId"));
      }
    }

    Map<Long, String> userImageUrls = attachmentService.getAttachmentPresignedUrlsForUserList(userIds, 9L);

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

  private JSONArray processCloserData(Integer timeInterval, boolean officeFdcRank) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("timeInterval", timeInterval);
    params.put("officeFdcRank", officeFdcRank);

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

  public List<Source> getBrsProvidedSources() {
    return sqlCache.query("closerDashboard.getBrsProvidedSources", null, Source.class);
  }

  public List<Source> getSelfGenSources() {
    return sqlCache.query("closerDashboard.getSelfGenSources", null, Source.class);
  }

  public String apptsCreatedPipeline(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_closer_funnel_appts_created_pipeline(:startDate::date, :endDate::date, array[ :brsProvidedSourceIds ]::integer[], array[ :selfGenSourceIds ]::integer[])";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", funnelRequest.getStart());
    parameters.addValue("endDate", funnelRequest.getEnd());
    parameters.addValue("brsProvidedSourceIds", funnelRequest.getBrsProvidedSources());
    parameters.addValue("selfGenSourceIds", funnelRequest.getSelfGenSources());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String apptsCreatedPipelineDrilldown(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_closer_funnel_appts_created_pipeline_drilldown(:startDate::date, :endDate::date, :funnelId::integer, array[ :sourceIds ]::integer[])";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", funnelRequest.getStart());
    parameters.addValue("endDate", funnelRequest.getEnd());
    parameters.addValue("funnelId", funnelRequest.getFunnelId());
    parameters.addValue("sourceIds", funnelRequest.getSources());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getDistricts(int userId, Boolean setterOverride) {
    String sqlQuery = "SELECT * FROM brs.util_closer_district_selection(:userId, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("setterOverride", setterOverride);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getRegions(int userId, String districts, Boolean setterOverride) {
    districts = districts.replace("%5B", "[").replace("%7B", "{").replace("%7D", "}").replace("%22", "\"").replace("%5D", "]");

    String sqlQuery = "SELECT * FROM brs.util_closer_region_selection(:userId, :districts::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("districts", districts);
    parameters.addValue("setterOverride", setterOverride);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getOffices(int userId, String regions, Boolean setterOverride) {
    regions = regions.replace("%5B", "[").replace("%7B", "{").replace("%7D", "}").replace("%22", "\"").replace("%5D", "]");

    String sqlQuery = "SELECT * FROM brs.util_closer_office_selection(:userId, :regions::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("regions", regions);
    parameters.addValue("setterOverride", setterOverride);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getReps(DashboardUserRequest req) {
    String sqlQuery = "SELECT * FROM brs.util_closer_rep_selection(:userId::int, :regions::JSON, :offices::JSON)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("regions", req.getRegions());
    parameters.addValue("offices", req.getOffices());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String funnelStandard(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_closer_funnel_standard(:startDate::date, :endDate::date, array[ :userIds ]::integer[], array[ :orgIds ]::integer[])";

    return runFunnelQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getUsers(), funnelRequest.getOrgs());
  }

  public String funnelApptDateCohort(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_closer_funnel_appt_date_cohort(:startDate::date, :endDate::date, array[ :userIds ]::integer[], array[ :orgIds ]::integer[])";

    return runFunnelQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getUsers(), funnelRequest.getOrgs());
  }

  private String runFunnelQuery(String sqlQuery, String start, String end, List<Long> userIds, List<Long> orgIds) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", start);
    parameters.addValue("endDate", end);
    parameters.addValue("userIds", userIds);
    parameters.addValue("orgIds", orgIds);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String funnelDrilldownStandard(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_closer_funnel_standard_drilldown(:startDate::date, :endDate::date, :funnelId::integer, array[ :userIds ]::integer[], array[ :orgIds ]::integer[], :isCheckedInColumn::boolean)";

    return runFunnelDrilldownQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getFunnelId(), funnelRequest.getUsers(), funnelRequest.getOrgs(), funnelRequest.getIsCheckedInColumn());
  }

  public String funnelDrilldownApptDateCohort(FunnelRequest funnelRequest) {
    String sqlQuery = "select brs.rpt_closer_funnel_appt_date_cohort_drilldown(:startDate::date, :endDate::date, :funnelId::integer, array[ :userIds ]::integer[], array[ :orgIds ]::integer[], :isCheckedInColumn::boolean)";

    return runFunnelDrilldownQuery(sqlQuery, funnelRequest.getStart(), funnelRequest.getEnd(), funnelRequest.getFunnelId(), funnelRequest.getUsers(), funnelRequest.getOrgs(), funnelRequest.getIsCheckedInColumn());
  }

  private String runFunnelDrilldownQuery(String sqlQuery, String start, String end, int funnelId, List<Long> userIds, List<Long> orgIds, Boolean isCheckedInColumn) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", start);
    parameters.addValue("endDate", end);
    parameters.addValue("funnelId", funnelId);
    parameters.addValue("userIds", userIds);
    parameters.addValue("orgIds", orgIds);
    parameters.addValue("isCheckedInColumn", isCheckedInColumn);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }
}
