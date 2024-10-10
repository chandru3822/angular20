package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.queries.CompanyDashboardQuery;
import com.albatross.api.v1.company.blueraven.services.queries.SetterDashboardQuery;
import com.albatross.api.v1.flow.enums.DataType;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.services.AttachmentService;
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
  private final AttachmentService attachmentService;

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

  public SetterPerformance getPerformanceReport(String startDate, String endDate) {
    Long currentUserId = securityService.getCurrentUser().getId();
    Map<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUserId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    Optional<SetterPerformance> optionalResult = sqlCache.getBySql(SetterDashboardQuery.getPerformanceReport, params, SetterPerformance.class);

//    if there is a setter to beat, get the image - this image stuff is currently only used by mobile
    if(optionalResult.isPresent()) {
      SetterPerformance result = optionalResult.get();
      if(null != result.getToBeatId()) {
        result.setImageUrl(attachmentService.getAttachmentPresignedUrl(result.getToBeatId(), 9L));
        result.setImageAltText("Photo of " + result.getToBeatName() + ", a Blue Raven Solar employee");
      } else if (Objects.equals(result.getCurrentRank(), "1")) {
        result.setToBeatName("You're #1!");
        result.setImageUrl(attachmentService.getAttachmentPresignedUrl(currentUserId, 9L));
      } else {
        result.setImageAltText("User photo placeholder");
      }
      return result;
    }

    return optionalResult.orElse(null);
  }

  public SetterPerformance getOfficePerformanceReport(String startDate, String endDate) {
    Map<String, Object> params = new HashMap<>();
    //dont use true id here
    params.put("userId", securityService.getCurrentUser().getId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    Optional<SetterPerformance> result = sqlCache.getBySql(SetterDashboardQuery.getOfficePerformanceReport, params, SetterPerformance.class);
    return result.orElse(null);
  }

  public List<TopRep> topReps(String startDate, String endDate, int limit) {
    Map<String, Object> params = new HashMap<>();
    params.put("limit", limit);
    params.put("userId", securityService.getCurrentUser().getId());
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    List<TopRep> topReps = sqlCache.queryBySql(SetterDashboardQuery.topReps, params, TopRep.class);

    for(TopRep rep : topReps) {
      rep.setUserImageUrl(attachmentService.getAttachmentPresignedUrl(rep.getUserId(), 9L));
      if(null != rep.getUserImageUrl()) {
        rep.setUserImageAltText("Photo of " + rep.getName() + ", a Blue Raven Solar Employee");
      } else {
        rep.setUserImageAltText("User photo placeholder");
      }
    }

    return topReps;
  }

  public List<OfficeRank> officeRanking(String startDate, String endDate, int limit) {
    Map<String, Object> params = new HashMap<>();
    params.put("limit", limit);
    params.put("startDate", startDate);
    params.put("endDate", endDate);

    List<OfficeRank> result = sqlCache.queryBySql(SetterDashboardQuery.officeRanking, params, OfficeRank.class);
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
    params.put("trendStart", funnelRequest.getTrendStart());
    params.put("trendEnd", funnelRequest.getTrendEnd());
    params.put("userIds", funnelRequest.getUsers());
    params.put("orgIds", funnelRequest.getOrgs());
    params.put("hideInactive", funnelRequest.getHideInactive());

    return sqlCache.queryForObjectBySql(SetterDashboardQuery.loadFunnel, params, String.class);
  }

  public String loadUpcomingAppointments(FunnelRequest funnelRequest){
    Map<String, Object> params = new HashMap<>();
    params.put("userIds", funnelRequest.getUsers());
    params.put("orgIds", funnelRequest.getOrgs());
    String result = sqlCache.queryForObjectBySql(SetterDashboardQuery.loadUpcomingAppointments, params, String.class);
    if(result == null){
      result = "[]";
    }
    return result;
  }

  public String funnelDrilldown(FunnelRequest funnelRequest) {
    Map<String, Object> params = new HashMap<>();
    params.put("startDate", funnelRequest.getStart());
    params.put("endDate", funnelRequest.getEnd());
    params.put("funnelId", funnelRequest.getFunnelId());
    params.put("userIds", funnelRequest.getUsers());
    params.put("orgIds", funnelRequest.getOrgs());
    params.put("hideInactive", funnelRequest.getHideInactive());

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

    if(isAdmin) {
      ranges.add(new CloserDashboardDateRange(5, "Last Period", "LAST_PERIOD",
        previousPeriod.getStartDate(),
        previousPeriod.getEndDate(),
        doublePreviousPeriod.getStartDate(),
        doublePreviousPeriod.getEndDate(), "the period before the last period"));
    }

    ranges.add(new CloserDashboardDateRange(6, "Week to Date", "WEEK_TO_DATE",
      currentWeekStart,
      today,
      lastWeekStart,
      lastWeekStart.plusDays(ChronoUnit.DAYS.between(currentWeekStart, today)), "the same timeframe last week"));

    ranges.add(new CloserDashboardDateRange(7, "Month to Date", "MONTH_TO_DATE",
      currentMonthStart,
      today,
      previousMonthStart,
      previousMonthStart.plusDays(ChronoUnit.DAYS.between(currentMonthStart, today)), "the same timeframe last month"));

    ranges.add(new CloserDashboardDateRange(8, "Period to Date", "PERIOD_TO_DATE",
      currentPeriod.getStartDate(),
      today,
      previousPeriod.getStartDate(),
      previousPeriod.getStartDate().plusDays(ChronoUnit.DAYS.between(currentPeriod.getStartDate(), today)), "the same timeframe last period"));

    ranges.add(new CloserDashboardDateRange(9, "Quarter to Date", "QUARTER_TO_DATE",
      triumvirate.getCurrentQuarterStart(),
      today,
      triumvirate.getLastQuarterStart(),
      triumvirate.getLastQuarterStart().plusDays(ChronoUnit.DAYS.between(triumvirate.getCurrentQuarterStart(), today)), "the same timeframe last period"));

    ranges.add(new CloserDashboardDateRange(10, "Year to Date", "YEAR_TO_DATE",
      currentYearStart,
      today,
      previousYearStart,
      previousYearStart.plusDays(ChronoUnit.DAYS.between(currentYearStart, today)), "the same timeframe last period"));

    if(isAdmin) {
      CloserDashboardDateRange periodRange = new CloserDashboardDateRange();
      periodRange.setId(11);
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

    ranges.add(new CloserDashboardDateRange(12, "Custom", "CUSTOM", null, null, null, null, null));

    return ranges;
  }

  public List<FunnelColumn> getFunnelColumns(Long id) {
    List<Long> nonNormalFunnelIds = new ArrayList<>(Arrays.asList(31L, 32L));

    ArrayList<FunnelColumn> allColumns = new ArrayList<>();

    allColumns.add(new FunnelColumn(1L, "Setter", "setter_name", 0L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(2L, "Name", "customer_name", 1L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(3L, "Project ID", "project_id", 2L, DataType.INTEGER.getId(), DataType.INTEGER.getDataType()));
    allColumns.add(new FunnelColumn(4L, "Appointment Date", "appointment_date", 3L, DataType.TIMESTAMP.getId(), DataType.TIMESTAMP.getDataType(), "MM/DD/YYYY"));
    allColumns.add(new FunnelColumn(5L, "Closer", "owner_name", 4L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    if (!nonNormalFunnelIds.contains(id)) {
      allColumns.add(new FunnelColumn(6L, "Verified Setter Lead", "verified_setter_lead", 5L, DataType.BOOLEAN.getId(), DataType.BOOLEAN.getDataType()));
      allColumns.add(new FunnelColumn(7L, "Appointment Outcome", "appointment_outcome", 6L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
      allColumns.add(new FunnelColumn(8L, "Checked In Time", "checked_in_time", 7L, DataType.TIMESTAMP.getId(), DataType.TIMESTAMP.getDataType()));
    }
    if (id == 31L) {
      allColumns.add(new FunnelColumn(9L, "Booking Date", "installation_agreement_signed_date", 8L, DataType.DATE.getId(), DataType.DATE.getDataType()));
    }
    if (id == 32L) {
      allColumns.add(new FunnelColumn(10L, "Final Design Complete Date", "final_design_complete_date", 9L, DataType.DATE.getId(), DataType.DATE.getDataType()));
    }
    allColumns.add(new FunnelColumn(11L, "Date Created", "date_created", 10L, DataType.TIMESTAMP.getId(), DataType.TIMESTAMP.getDataType(), "MM/DD/YYYY"));
    allColumns.add(new FunnelColumn(12L, "State", "state", 11L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(13L, "Office", "office", 12L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));

    return allColumns;
  }
}
