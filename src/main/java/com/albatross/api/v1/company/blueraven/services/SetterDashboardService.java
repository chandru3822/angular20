package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.queries.CompanyDashboardQuery;
import com.albatross.api.v1.company.blueraven.services.queries.SetterDashboardQuery;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

import static java.time.temporal.TemporalAdjusters.*;
import static java.time.temporal.TemporalAdjusters.nextOrSame;
import java.time.temporal.ChronoUnit;

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

  public ArrayList<CloserDashboardDateRange> getDropdownValues(LocalDate today) {
    Boolean isAdmin = securityService.getCurrentUser().isSystemAdmin();
    if(!isAdmin) {
      for (FeatureAccessControl feature : securityService.getCurrentUser().getFeatureAccess()) {
        if (feature.getFeatureCode().equalsIgnoreCase("COMPANY_DASHBOARD") && feature.getAccessCode().equalsIgnoreCase("ADMIN")) {
          isAdmin = true;
        }
      }
    }
    ArrayList<CloserDashboardDateRange> ranges = new ArrayList<>();
    HashMap<String, Object> params = new HashMap<>();
    params.put("today", today.toString());
    List<CompanyPeriod> companyPeriods = sqlCache.queryBySql(CompanyDashboardQuery.getCompanyDashboardPeriods, params, CompanyPeriod.class);
    CompanyPeriod currentPeriod = null;
    CompanyPeriod previousPeriod = null;
    CompanyPeriod doublePreviousPeriod = null;
    Integer currentIndex = null;

    for (CompanyPeriod period : companyPeriods) {
      if (today.isBefore(period.getEndDate()) || today.isEqual(period.getEndDate())) {
        currentPeriod = period;
        currentIndex = companyPeriods.indexOf(period);
        previousPeriod = companyPeriods.get(currentIndex - 1);
        doublePreviousPeriod = companyPeriods.get(currentIndex - 2);
      }
    }

    YearMonth month = YearMonth.from(today);
    LocalDate currentMonthStart = month.atDay(1);
    LocalDate currentMonthEnd = month.atEndOfMonth();
    LocalDate previousMonthStart = today.minusMonths(1).withDayOfMonth(1);
    LocalDate previousMonthEnd = currentMonthStart.minusDays(1);
    LocalDate penultimateMonthStart = today.minusMonths(2).withDayOfMonth(1);
    LocalDate penultimateMonthEnd = previousMonthStart.minusDays(1);
    LocalDate currentYearStart = today.with(firstDayOfYear());
    LocalDate currentYearEnd = today.with(lastDayOfYear());
    LocalDate previousYearEnd = currentYearStart.minusDays(1);
    LocalDate previousYearStart = previousYearEnd.with(firstDayOfYear());


    Triumvirate triumvirate = sqlCache.queryBySql(CompanyDashboardQuery.getGetCompanyDashboardTriumvirate, params, Triumvirate.class).get(0);

    DayOfWeek weekStart = DayOfWeek.MONDAY;
    DayOfWeek weekEnd = DayOfWeek.SUNDAY;
    LocalDate currentWeekStart = today.with(previousOrSame(weekStart));
    LocalDate currentWeekEnd = today.with(nextOrSame(weekEnd));
    LocalDate lastWeekStart = currentWeekStart.minusDays(7);
    LocalDate lastWeekEnd = currentWeekEnd.minusDays(7);
    LocalDate yesterday = today.minusDays(1);
    LocalDate tomorrow = today.plusDays(1);

    ranges.add(new CloserDashboardDateRange(1, "Yesterday", "YESTERDAY",
      yesterday,
      yesterday,
      yesterday.minusDays(1),
      yesterday.minusDays(1), "the day before yesterday"));

    ranges.add(new CloserDashboardDateRange(2, "Today", "TODAY",
      today, today, yesterday, yesterday, "yesterday"));

    ranges.add(new CloserDashboardDateRange(3, "Last Week", "LAST WEEK",
      lastWeekStart,
      lastWeekEnd,
      lastWeekStart.minusDays(7),
      lastWeekEnd.minusDays(7), "the week before last week"));

    ranges.add(new CloserDashboardDateRange(4, "Last Month", "LAST_MONTH",
      previousMonthStart,
      previousMonthEnd,
      penultimateMonthStart,
      penultimateMonthEnd, "the month before the last month"));

    ranges.add(new CloserDashboardDateRange(5, "Last 7 Days", "LAST_7_DAYS",
      today.minusDays(7),
      today,
      today.minusDays(8),
      today.minusDays(14), "7 days before last 7 days"));

    ranges.add(new CloserDashboardDateRange(6, "Last 30 Days", "LAST_30_DAYS",
      today.minusDays(30),
      today,
      today.minusDays(31),
      today.minusDays(60), "30 days before last 30 days"));

    ranges.add(new CloserDashboardDateRange(7, "Last 90 Days", "LAST_90_DAYS",
      today.minusDays(90),
      today,
      today.minusDays(91),
      today.minusDays(180), "90 days before last 90 days"));

    ranges.add(new CloserDashboardDateRange(8, "Week to Date", "WEEK_TO_DATE",
      currentWeekStart,
      today,
      lastWeekStart,
      lastWeekStart.plusDays(ChronoUnit.DAYS.between(currentWeekStart, today)), "the same timeframe last week"));

    ranges.add(new CloserDashboardDateRange(9, "Month to Date", "MONTH_TO_DATE",
      currentMonthStart,
      today,
      previousMonthStart,
      previousMonthStart.plusDays(ChronoUnit.DAYS.between(currentMonthStart, today)), "the same timeframe last month"));

    ranges.add(new CloserDashboardDateRange(10, "Quarter to Date", "QUARTER_TO_DATE",
      triumvirate.getCurrentQuarterStart(),
      today,
      triumvirate.getLastQuarterStart(),
      triumvirate.getLastQuarterStart().plusDays(ChronoUnit.DAYS.between(triumvirate.getCurrentQuarterStart(), today)), "the same timeframe last period"));

    ranges.add(new CloserDashboardDateRange(11, "Year to Date", "YEAR_TO_DATE",
      currentYearStart,
      today,
      previousYearStart,
      previousYearStart.plusDays(ChronoUnit.DAYS.between(currentYearStart, today)), "the same timeframe last period"));

    if(isAdmin) {
      CloserDashboardDateRange periodRange = new CloserDashboardDateRange();
      periodRange.setId(12);
      Collections.reverse(companyPeriods);
      for(int x=1; x<companyPeriods.size(); x++){
        if(x > 0){
          companyPeriods.get(x).setTrendStart(companyPeriods.get(x-1).getStartDate());
          companyPeriods.get(x).setTrendEnd(companyPeriods.get(x-1).getEndDate());
        }
      }
      periodRange.setPeriodList(companyPeriods);
      periodRange.setTrendText("the period before the selected period");
      periodRange.setFriendlyName("Period");
      periodRange.setName("PERIOD");
      ranges.add(periodRange);
    }

    ranges.add(new CloserDashboardDateRange(13, "Custom", "CUSTOM", null, null, null, null, null));

    return ranges;
  }
}
