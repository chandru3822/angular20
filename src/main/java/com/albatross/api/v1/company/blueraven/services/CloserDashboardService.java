package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.queries.CloserDashboardQuery;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.postalCode.PostalCodeZone;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@PreAuthorize("(hasCompanyAccess(3) || hasCompanyAccess(18)) && hasFeatureAccess('CLOSER_DASHBOARD')")
@RequiredArgsConstructor
public class CloserDashboardService {

  private final AttachmentService attachmentService;
  private final SecurityService securityService;
  private final SqlCache sqlCache;
  private final NamedParameterJdbcTemplate jdbc;

  public IncentiveCounts getIncentiveFdcCounts() {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());

    return sqlCache
        .queryBySql(CloserDashboardQuery.getIncentiveFdcCounts, params, IncentiveCounts.class)
        .get(0);
  }

  public String finalDesignsCompletedDrilldown(int quarter) {
    String sqlQuery =
        "SELECT * FROM brs.get_final_designs_completed_drilldown(:userId::bigint, :quarter::bigint)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("quarter", quarter);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public List<PostalCodeZone> getRoundRobins() {
    User user = securityService.getCurrentUser();
    Boolean viewAll =
        securityService.userHasFeatureAccessLevel(
            user.getId(),
            user.getCompanyId(),
            user.getHighestCompanyId(),
            "CLOSER_DASHBOARD",
            List.of("VIEW_ALL"));

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("viewAll", viewAll);
    params.put("companyId", user.getCompanyId());

    if (viewAll) {
      return sqlCache.queryBySql(CloserDashboardQuery.getAllRoundRobins, params, PostalCodeZone.class);
    }
    else {
      return sqlCache.queryBySql(CloserDashboardQuery.getRoundRobins, params, PostalCodeZone.class);
    }
  }

  public List<RoundRobinLeadAllocationScores> getRoundRobinLeadAllocationRank(
      Integer postalCodeZoneId, Integer timeInterval) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCodeZoneId", postalCodeZoneId);
    params.put("timeInterval", timeInterval);
    params.put("currentUserId", securityService.getCurrentUser().getId());

    List<RoundRobinLeadAllocationScores> roundRobinLeadAllocationData =
        sqlCache.queryBySql(
            CloserDashboardQuery.getRoundRobinLeadAllocationRank,
            params,
            RoundRobinLeadAllocationScores.class);
    List<Long> userIds = new ArrayList<>();

    for (RoundRobinLeadAllocationScores row : roundRobinLeadAllocationData) {
      userIds.add(row.getUserId());
    }

    Map<Long, String> userImageUrls = getUserImages(userIds);

    for (RoundRobinLeadAllocationScores row : roundRobinLeadAllocationData) {
      if (userImageUrls.get(row.getUserId()) != null) {
        row.setUserImageUrl(userImageUrls.get(row.getUserId()));
        row.setUserImageAltText(
            "Photo of " + row.getCloserName() + ", a Blue Raven Solar employee");
      } else {
        row.setUserImageAltText("User photo placeholder");
      }
    }

    return roundRobinLeadAllocationData;
  }

  public List<Org> getCloserOffices(Long userOrgId) {
    User user = securityService.getCurrentUser();
    Boolean viewCustom =
        securityService.userHasFeatureAccessLevel(
            user.getId(),
            user.getCompanyId(),
            user.getHighestCompanyId(),
            "CLOSER_DASHBOARD",
            List.of("VIEW_CUSTOM"));
    Boolean viewAll =
        securityService.userHasFeatureAccessLevel(
            user.getId(),
            user.getCompanyId(),
            user.getHighestCompanyId(),
            "CLOSER_DASHBOARD",
            List.of("VIEW_ALL"));

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    if (viewAll) {
      return sqlCache.queryBySql(CloserDashboardQuery.getAllCloserOffices, params, Org.class);
    } else {
      params.put("userOrgId", userOrgId);

      if (viewCustom) {
        return sqlCache.queryBySql(CloserDashboardQuery.getCloserDownline, params, Org.class);
      }
      else {
        return sqlCache.queryBySql(CloserDashboardQuery.getCloserOffice, params, Org.class);
      }
    }
  }

  public String getCloserTableScores(
      Integer timeInterval, Boolean officeFdcRank, Long selectedOrgId) {
    JSONObject closerDashboardData = new JSONObject();

    if (officeFdcRank) {
      closerDashboardData.put(
          "officeFdcRankValues", processCloserData(timeInterval, true, selectedOrgId));
      return getUserImages("officeFdcRankValues", closerDashboardData);
    } else {
      closerDashboardData.put("companyRankingValues", processCloserData(timeInterval, false, null));
      return getUserImages("companyRankingValues", closerDashboardData);
    }
  }

  public Map<Long, String> getUserImages(List<Long> userIds) {
    return attachmentService.getAttachmentPresignedUrlsForUserList(userIds, 9L);
  }

  public String getUserImages(String key, JSONObject closerDashboardData) {
    List<Long> userIds = new ArrayList<>();

    for (Object row : closerDashboardData.getJSONArray(key)) {
      JSONObject rowObject = (JSONObject) row;
      userIds.add(rowObject.getLong("userId"));
    }

    Map<Long, String> userImageUrls =
        attachmentService.getAttachmentPresignedUrlsForUserList(userIds, 9L);

    for (Object row : closerDashboardData.getJSONArray(key)) {
      JSONObject rowObject = (JSONObject) row;

      if (userImageUrls.get(rowObject.getLong("userId")) != null) {
        rowObject.put("userImageUrl", userImageUrls.get(rowObject.getLong("userId")));
        rowObject.put(
            "userImageAltText",
            "Photo of " + rowObject.get("name") + ", a Blue Raven Solar employee");
      } else {
        rowObject.put("userImageAltText", "User photo placeholder");
      }
    }

    return closerDashboardData.toString();
  }

  private JSONArray processCloserData(
      Integer timeInterval, boolean officeFdcRank, Long selectedOrgId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("timeInterval", timeInterval);
    params.put("officeFdcRank", officeFdcRank);
    params.put("selectedOrgId", selectedOrgId);

    List<CloserTableScores> closerTableScores = officeFdcRank
      ? sqlCache.queryBySql(CloserDashboardQuery.getCloserTableScoresOffice, params, CloserTableScores.class)
      : sqlCache.queryBySql(CloserDashboardQuery.getCloserTableScoresRep, params, CloserTableScores.class);

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
          leadGenFdcValue =
              ((double) row.getLeadGenFdcPercentageNumerator()
                  / row.getLeadGenFdcPercentageDenominator());
        }
        closerTableScoresJson.put(
            "leadGenFdcPercentage", new DecimalFormat("#.#").format(leadGenFdcValue * 100));

        closerTableScoresJson.put("selfGenFdc", row.getSelfGenFdc());
        closerTableScoresJson.put("totalFdc", row.getTotalFdc());

        closerTableScoresArray.put(closerTableScoresJson);
      } catch (Exception e) {
        log.error("CLOSER DASH: exception", e);
      }
    }
    return closerTableScoresArray;
  }

  public List<Source> getBrsProvidedSources() {
    return sqlCache.queryBySql(CloserDashboardQuery.getBrsProvidedSources, null, Source.class);
  }

  public List<Source> getSelfGenSources() {
    return sqlCache.queryBySql(CloserDashboardQuery.getSelfGenSources, null, Source.class);
  }

  public String apptsCreatedPipeline(FunnelRequest funnelRequest) {
    String sqlQuery =
        "select brs.rpt_closer_funnel_appts_created_pipeline(:startDate::date, :endDate::date, array[ :brsProvidedSourceIds ]::bigint[], array[ :selfGenSourceIds ]::bigint[], :currentUserId::bigint)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", funnelRequest.getStart());
    parameters.addValue("endDate", funnelRequest.getEnd());
    parameters.addValue("brsProvidedSourceIds", funnelRequest.getBrsProvidedSources());
    parameters.addValue("selfGenSourceIds", funnelRequest.getSelfGenSources());
    parameters.addValue("currentUserId", securityService.getCurrentUser().trueUserId());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String apptsCreatedPipelineDrilldown(FunnelRequest funnelRequest) {
    String sqlQuery =
        "select brs.rpt_closer_funnel_appts_created_pipeline_drilldown(:startDate::date, :endDate::date, :funnelId::bigint, array[ :sourceIds ]::bigint[], :currentUserId::bigint)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", funnelRequest.getStart());
    parameters.addValue("endDate", funnelRequest.getEnd());
    parameters.addValue("funnelId", funnelRequest.getFunnelId());
    parameters.addValue("sourceIds", funnelRequest.getSources());
    parameters.addValue("currentUserId", securityService.getCurrentUser().trueUserId());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getAreas(DashboardUserRequest req) {
    String sqlQuery =
        "SELECT * FROM brs.util_closer_area_selection(:userId::bigint, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("setterOverride", req.getSetterOverride());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getRegions(DashboardUserRequest req) {
    String sqlQuery =
        "SELECT * FROM brs.util_closer_region_selection(:userId::bigint, :areas::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("areas", req.getAreas());
    parameters.addValue("setterOverride", req.getSetterOverride());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getDistricts(DashboardUserRequest req) {
    String sqlQuery =
        "SELECT * FROM brs.util_closer_district_selection(:userId::bigint, :areas::JSON, :regions::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("areas", req.getAreas());
    parameters.addValue("regions", req.getRegions());
    parameters.addValue("setterOverride", req.getSetterOverride());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getOffices(DashboardUserRequest req) {
    String sqlQuery =
        "SELECT * FROM brs.util_closer_office_selection(:userId::bigint, :areas::JSON, :regions::JSON, :districts::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", req.getUserId());
    parameters.addValue("areas", req.getAreas());
    parameters.addValue("regions", req.getRegions());
    parameters.addValue("districts", req.getDistricts());
    parameters.addValue("setterOverride", req.getSetterOverride());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getReps(DashboardUserRequest req) {
    String sqlQuery =
        "SELECT * FROM brs.util_closer_rep_selection(:userId::bigint, :areas::JSON, :regions::JSON, :districts::JSON, :offices::JSON)";

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
    String sqlQuery;
    sqlQuery =
        "select brs.rpt_closer_funnel_standard(:startDate::date, :endDate::date, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], :currentUserId::bigint)";

    return runFunnelQuery(
        sqlQuery,
        funnelRequest.getStart(),
        funnelRequest.getEnd(),
        funnelRequest.getUsers(),
        funnelRequest.getOrgs());
  }

  public String funnelApptDateCohort(FunnelRequest funnelRequest) {
    String sqlQuery =
        "select brs.rpt_closer_funnel_appt_date_cohort(:startDate::date, :endDate::date, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], :currentUserId::bigint)";

    return runFunnelQuery(
        sqlQuery,
        funnelRequest.getStart(),
        funnelRequest.getEnd(),
        funnelRequest.getUsers(),
        funnelRequest.getOrgs());
  }

  private String runFunnelQuery(
      String sqlQuery, String start, String end, List<Long> userIds, List<Long> orgIds) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", start);
    parameters.addValue("endDate", end);
    parameters.addValue("userIds", userIds);
    parameters.addValue("orgIds", orgIds);
    parameters.addValue("currentUserId", securityService.getCurrentUser().trueUserId());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String funnelDrilldownStandard(FunnelRequest funnelRequest) {
    String sqlQuery =
        "select brs.rpt_closer_funnel_standard_and_cohort_drilldown(:startDate::date, :endDate::date, :funnelId::bigint, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], :isCheckedInColumn::boolean, false, :currentUserId::bigint)";

    return runFunnelDrilldownQuery(
        sqlQuery,
        funnelRequest.getStart(),
        funnelRequest.getEnd(),
        funnelRequest.getFunnelId(),
        funnelRequest.getUsers(),
        funnelRequest.getOrgs(),
        funnelRequest.getIsCheckedInColumn());
  }

  public String funnelDrilldownApptDateCohort(FunnelRequest funnelRequest) {
    String sqlQuery =
        "select brs.rpt_closer_funnel_standard_and_cohort_drilldown(:startDate::date, :endDate::date, :funnelId::bigint, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], :isCheckedInColumn::boolean, true, :currentUserId::bigint)";

    return runFunnelDrilldownQuery(
        sqlQuery,
        funnelRequest.getStart(),
        funnelRequest.getEnd(),
        funnelRequest.getFunnelId(),
        funnelRequest.getUsers(),
        funnelRequest.getOrgs(),
        funnelRequest.getIsCheckedInColumn());
  }

  private String runFunnelDrilldownQuery(
      String sqlQuery,
      String start,
      String end,
      int funnelId,
      List<Long> userIds,
      List<Long> orgIds,
      Boolean isCheckedInColumn) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", start);
    parameters.addValue("endDate", end);
    parameters.addValue("funnelId", funnelId);
    parameters.addValue("userIds", userIds);
    parameters.addValue("orgIds", orgIds);
    parameters.addValue("isCheckedInColumn", isCheckedInColumn);
    parameters.addValue("currentUserId", securityService.getCurrentUser().trueUserId());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }
}
