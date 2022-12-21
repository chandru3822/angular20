package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CompanyDashboardTargets;
import com.albatross.api.v1.company.blueraven.services.queries.CompanyDashboardQuery;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.Maps;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.Month;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CompanyDashboardService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  // Used to keep track of the week the feature was released and the first week values are kept for
  private LocalDate startOfTrackingDate = LocalDate.of(2019, Month.NOVEMBER, 25);

  public List<CompanyDashboardTargets> getTargets() {
    populateDates();

    return sqlCache.queryBySql(CompanyDashboardQuery.getTargets, null, CompanyDashboardTargets.class);
  }

  public String getWeekTargets(java.sql.Date targetDate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("targetDate", targetDate);
    return sqlCache.queryForObjectBySql(CompanyDashboardQuery.getWeekTargets, params, String.class);
  }

  /*
     Checks to see if any weeks are missing from the DB table
     The user is able to enter values for each week starting at startOfTrackingDate
     We store the Monday for the given week, if any Mondays up to this week's Monday are missing, we add them here
   */
  private void populateDates() {
    LocalDate nextMonday = LocalDate.now().with(DayOfWeek.MONDAY).plusWeeks(1);
    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd", Locale.ENGLISH);

    // Get all of the dates already in the DB
    String existingDates = sqlCache.queryForObjectBySql(CompanyDashboardQuery.getDates, Maps.newHashMap(), String.class);
    LocalDate currentTrackDate = startOfTrackingDate;
    // Check to see if any Monday is missing from the starting Date (11/25/19) until next week's Monday
    while (currentTrackDate.isBefore(nextMonday) || currentTrackDate.isEqual(nextMonday)) {
      String dateToAdd = dateFormat.format(currentTrackDate);
      // If the date is not in the DB, insert it
      if (existingDates == null || !existingDates.contains(dateToAdd)) {
        HashMap<String, Object> params = new HashMap<>();
        String prevTargets = getWeekTargets(java.sql.Date.valueOf(currentTrackDate.minusWeeks(1)));
        JSONObject latestTargetsJson = new JSONObject(prevTargets.substring(1, prevTargets.length() - 1));
        params.put("bookingsBrs", latestTargetsJson.isNull("bookings_brs") ? null : latestTargetsJson.get("bookings_brs"));
        params.put("bookingsPartner", latestTargetsJson.isNull("bookings_partner") ? null : latestTargetsJson.get("bookings_partner"));
        params.put("finalDesignsCompletedBrs", latestTargetsJson.isNull("final_designs_completed_brs") ? null : latestTargetsJson.get("final_designs_completed_brs"));
        params.put("finalDesignsCompletedPartner", latestTargetsJson.isNull("final_designs_completed_partner") ? null : latestTargetsJson.get("final_designs_completed_partner"));
        params.put("substantialCompletionsBrs", latestTargetsJson.isNull("substantial_completions_brs") ? null : latestTargetsJson.get("substantial_completions_brs"));
        params.put("substantialCompletionsPartner", latestTargetsJson.isNull("substantial_completions_partner") ? null : latestTargetsJson.get("substantial_completions_partner"));
        params.put("finalCompletionsBrs", latestTargetsJson.isNull("final_completions_partner") ? null : latestTargetsJson.get("final_completions_brs"));
        params.put("finalCompletionsPartner", latestTargetsJson.isNull("final_completions_partner") ? null : latestTargetsJson.get("final_completions_partner"));
        params.put("targetDate", java.sql.Date.valueOf(currentTrackDate));
        sqlCache.updateBySql(CompanyDashboardQuery.insertTargets, params);
      }
      currentTrackDate = currentTrackDate.plusWeeks(1);
    }
  }

  public void updateTargets(List<CompanyDashboardTargets> targetValueRows) {
    for (CompanyDashboardTargets targetValueRow : targetValueRows) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("id", targetValueRow.getId());
      params.put("bookingsBrs", targetValueRow.getBookingsBrs());
      params.put("bookingsPartner", targetValueRow.getBookingsPartner());
      params.put("finalDesignsCompletedBrs", targetValueRow.getFinalDesignsCompletedBrs());
      params.put("finalDesignsCompletedPartner", targetValueRow.getFinalDesignsCompletedPartner());
      params.put("substantialCompletionsBrs", targetValueRow.getSubstantialCompletionsBrs());
      params.put("substantialCompletionsPartner", targetValueRow.getSubstantialCompletionsPartner());
      params.put("finalCompletionsBrs", targetValueRow.getFinalCompletionsBrs());
      params.put("finalCompletionsPartner", targetValueRow.getFinalCompletionsPartner());

      sqlCache.updateBySql(CompanyDashboardQuery.updateTargets, params);
    }
  }

  public String getDashboardValues(String startDate, String endDate, Long targetTypeId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("companyId", user.getCompanyId());
    params.put("targetTypeId", targetTypeId);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String results = sqlCache.queryForObjectBySql(CompanyDashboardQuery.getCompanyDashboard, params, String.class);
    return results;
  }

  public String getDrilldownValues(String startDate, String endDate, Long milestoneTypeId, Boolean loadPartners) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("companyId", user.getCompanyId());
    params.put("milestoneTypeId", milestoneTypeId);
    params.put("loadPartners", loadPartners);
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());

    String results = sqlCache.queryForObjectBySql(CompanyDashboardQuery.getCompanyDashboardDrilldown, params, String.class);
    return results;
  }
}
