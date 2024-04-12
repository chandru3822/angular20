package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.queries.CloserDashboardQuery;
import com.albatross.api.v1.company.blueraven.services.queries.CompanyDashboardQuery;
import com.albatross.api.v1.flow.enums.DataType;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.roundRobin.RoundRobin;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.text.DecimalFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

import static java.time.temporal.TemporalAdjusters.*;
import static java.time.temporal.TemporalAdjusters.nextOrSame;

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

  public String getCloserResiduals(String residualDate, Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", null != userId ? userId : user.getId());
    params.put("residualDate", residualDate);

    return sqlCache
             .getBySql(CloserDashboardQuery.getCloserResiduals, params, new SingleColumnRowMapper<>(String.class))
             .orElse("{}");
  }


  public List<User> getClosers(Boolean showInactive) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("showInactive", showInactive);

    return sqlCache.queryBySql(CloserDashboardQuery.getClosers, params, User.class);
  }

  public String finalDesignsCompletedDrilldown(int quarter) {
    String sqlQuery =
        "SELECT * FROM brs.get_final_designs_completed_drilldown(:userId::bigint, :quarter::bigint)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("quarter", quarter);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public List<RoundRobin> getRoundRobins() {
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
      return sqlCache.queryBySql(CloserDashboardQuery.getAllRoundRobins, params, RoundRobin.class);
    }
    else {
      return sqlCache.queryBySql(CloserDashboardQuery.getRoundRobins, params, RoundRobin.class);
    }
  }

  public List<CloserTableScore> getRoundRobinLeadAllocationRank(
      Integer roundRobinId, Integer timeInterval) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", roundRobinId);
    params.put("timeInterval", timeInterval);
    params.put("currentUserId", securityService.getCurrentUser().getId());

    List<CloserTableScore> roundRobinLeadAllocationData =
        sqlCache.queryBySql(
            CloserDashboardQuery.getRoundRobinLeadAllocationRank,
            params,
          CloserTableScore.class);

    getUserImages(roundRobinLeadAllocationData);

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

  public List<CloserTableScore> getRepRankings(Integer timeInterval, Long selectedOrgId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("timeInterval", timeInterval);
    params.put("selectedOrgId", selectedOrgId);

    List<CloserTableScore> closerTableScores = sqlCache.queryBySql(CloserDashboardQuery.getCloserRankings, params, CloserTableScore.class);

    //process the user images
    getUserImages(closerTableScores);

    return closerTableScores;
  }

  public List<CloserTableScore> getCloserOrgRankings(Integer timeInterval) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().getId());
    params.put("timeInterval", timeInterval);

    List<CloserTableScore> closerTableScores = sqlCache.queryBySql(CloserDashboardQuery.getCloserOrgRankings, params, CloserTableScore.class);

    return closerTableScores;
  }

  public void getUserImages(List<CloserTableScore> scores) {
    List<Long> userIds = scores.stream().map(CloserTableScore::getUserId).collect(Collectors.toList());

    Map<Long, String> userImageUrls =
        attachmentService.getAttachmentPresignedUrlsForUserList(userIds, 9L);

    for (CloserTableScore score : scores) {
      String imageUrl = userImageUrls.get(score.getUserId());
      if (imageUrl != null) {
        score.setUserImageUrl(imageUrl);
        score.setUserImageAltText(
            "Photo of " + score.getCloserName() + ", a Blue Raven Solar employee");
      } else {
        score.setUserImageAltText("User photo placeholder");
      }
    }
  }

  public List<Source> getBrsProvidedSources() {
    return sqlCache.queryBySql(CloserDashboardQuery.getBrsProvidedSources, null, Source.class);
  }

  public List<Source> getSelfGenSources() {
    return sqlCache.queryBySql(CloserDashboardQuery.getSelfGenSources, null, Source.class);
  }

  public String apptsCreatedPipeline(FunnelRequest funnelRequest) {
    String sqlQuery =
        "select brs.rpt_closer_funnel_appts_created_pipeline(:startDate::date, :endDate::date, :trendStart::date, :trendEnd::date, array[ :brsProvidedSourceIds ]::bigint[], array[ :selfGenSourceIds ]::bigint[], array[ :leadsCreatedSourceIds ]::bigint[])";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", funnelRequest.getStart());
    parameters.addValue("endDate", funnelRequest.getEnd());
    parameters.addValue("trendStart", funnelRequest.getTrendStart());
    parameters.addValue("trendEnd", funnelRequest.getTrendEnd());
    parameters.addValue("brsProvidedSourceIds", funnelRequest.getBrsProvidedSources());
    parameters.addValue("selfGenSourceIds", funnelRequest.getSelfGenSources());
    parameters.addValue("leadsCreatedSourceIds", funnelRequest.getLeadsCreatedSources());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String apptsCreatedPipelineDrilldown(FunnelRequest funnelRequest) {
    String sqlQuery =
        "select brs.rpt_closer_funnel_appts_created_pipeline_drilldown(:startDate::date, :endDate::date, :funnelId::bigint, array[ :sourceIds ]::bigint[])";
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", funnelRequest.getStart());
    parameters.addValue("endDate", funnelRequest.getEnd());
    parameters.addValue("funnelId", funnelRequest.getFunnelId());
    parameters.addValue("sourceIds", funnelRequest.getSources());

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String getAreas(DashboardUserRequest req) {
    String sqlQuery =
        "SELECT * FROM brs.util_closer_area_selection(:userId::bigint, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("setterOverride", req.getSetterOverride());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getRegions(DashboardUserRequest req) {
    String sqlQuery =
        "SELECT * FROM brs.util_closer_region_selection(:userId::bigint, :areas::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("areas", req.getAreas());
    parameters.addValue("setterOverride", req.getSetterOverride());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public String getDistricts(DashboardUserRequest req) {
    String sqlQuery =
        "SELECT * FROM brs.util_closer_district_selection(:userId::bigint, :areas::JSON, :regions::JSON, :setterOverride::BOOLEAN)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", securityService.getCurrentUser().getId());
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
    parameters.addValue("userId", securityService.getCurrentUser().getId());
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
    parameters.addValue("userId", securityService.getCurrentUser().getId());
    parameters.addValue("areas", req.getAreas());
    parameters.addValue("regions", req.getRegions());
    parameters.addValue("districts", req.getDistricts());
    parameters.addValue("offices", req.getOffices());

    String results = jdbc.queryForObject(sqlQuery, parameters, String.class);
    return null == results ? "[]" : results;
  }

  public List<AppointmentType> getAppointmentTypes(){
    List<AppointmentType> appointmentTypes = new ArrayList<>();
    appointmentTypes.add(new AppointmentType("Round Robin", (long) 1));
    appointmentTypes.add(new AppointmentType("Manual", (long) 2));

    return appointmentTypes;
  }

  public String funnelStandard(FunnelRequest funnelRequest) {
    String sqlQuery;
    sqlQuery =
        "select brs.rpt_closer_funnel_standard(:startDate::date, :endDate::date, :trendStart::date, :trendEnd::date, array[ :userIds ]::bigint[], array[ :appointmentTypeIds ]::bigint[], array[ :leadSourceIds ]::bigint[], :hideInactive::boolean)";

    return runFunnelQuery(
        sqlQuery,
        funnelRequest.getStart(),
        funnelRequest.getEnd(),
        funnelRequest.getTrendStart(),
        funnelRequest.getTrendEnd(),
        funnelRequest.getUsers(),
        funnelRequest.getAppointmentTypeIds(),
        funnelRequest.getLeadSourceIds(),
        funnelRequest.getHideInactive());
  }

//  public String funnelApptDateCohort(FunnelRequest funnelRequest) {
//    String sqlQuery =
//        "select brs.rpt_closer_funnel_appt_date_cohort(:startDate::date, :endDate::date, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], :currentUserId::bigint)";
//
//    return runFunnelQuery(
//        sqlQuery,
//        funnelRequest.getStart(),
//        funnelRequest.getEnd(),
//        funnelRequest.getUsers(),
//        funnelRequest.getOrgs());
//  }

  private String runFunnelQuery(
      String sqlQuery, String start, String end, String trendStart, String trendEnd, List<Long> userIds, List<Long> appointmentTypeIds, List<Long> leadSourceIds, Boolean hideInactive) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", start);
    parameters.addValue("endDate", end);
    parameters.addValue("trendStart", trendStart);
    parameters.addValue("trendEnd", trendEnd);
    parameters.addValue("userIds", userIds);
    parameters.addValue("appointmentTypeIds", appointmentTypeIds);
    parameters.addValue("leadSourceIds", leadSourceIds);
    parameters.addValue("hideInactive", hideInactive);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public String funnelDrilldownStandard(FunnelRequest funnelRequest) {
    String sqlQuery =
        "select brs.rpt_closer_funnel_standard_drilldown(:startDate::date, :endDate::date, :funnelId::bigint, array[ :userIds ]::bigint[], :isCheckedInColumn::boolean, array[ :appointmentTypeIds ]::bigint[], array[ :leadSourceIds ]::bigint[], :hideInactive::boolean)";

    return runFunnelDrilldownQuery(
        sqlQuery,
        funnelRequest.getStart(),
        funnelRequest.getEnd(),
        funnelRequest.getFunnelId(),
        funnelRequest.getUsers(),
        funnelRequest.getIsCheckedInColumn(),
        funnelRequest.getAppointmentTypeIds(),
        funnelRequest.getLeadSourceIds(),
        funnelRequest.getHideInactive());
  }

//  public String funnelDrilldownApptDateCohort(FunnelRequest funnelRequest) {
//    String sqlQuery =
//        "select brs.rpt_closer_funnel_standard_and_cohort_drilldown(:startDate::date, :endDate::date, :funnelId::bigint, array[ :userIds ]::bigint[], array[ :orgIds ]::bigint[], :isCheckedInColumn::boolean, true, :currentUserId::bigint)";
//
//    return runFunnelDrilldownQuery(
//        sqlQuery,
//        funnelRequest.getStart(),
//        funnelRequest.getEnd(),
//        funnelRequest.getFunnelId(),
//        funnelRequest.getUsers(),
//        funnelRequest.getOrgs(),
//        funnelRequest.getIsCheckedInColumn());
//  }

  private String runFunnelDrilldownQuery(
      String sqlQuery,
      String start,
      String end,
      int funnelId,
      List<Long> userIds,
      Boolean isCheckedInColumn,
      List<Long> appointmentTypeIds,
      List<Long> leadSourceIds,
      Boolean hideInactive) {
    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("startDate", start);
    parameters.addValue("endDate", end);
    parameters.addValue("funnelId", funnelId);
    parameters.addValue("userIds", userIds);
    parameters.addValue("isCheckedInColumn", isCheckedInColumn);
    parameters.addValue("appointmentTypeIds", appointmentTypeIds);
    parameters.addValue("leadSourceIds", leadSourceIds);
    parameters.addValue("hideInactive", hideInactive);
    System.out.println(parameters);

    return jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  public List<LeaderboardBooking> getLeaderboardBookings(String bookingDate) {
    Map<String, Object> params = new HashMap<>();
    params.put("bookingDate", bookingDate);


    List<LeaderboardBooking> results = sqlCache.queryBySql(CloserDashboardQuery.getLeaderboardBookings, params, LeaderboardBooking.class);
    return results;
  }

  public List<FunnelColumn> getFunnelColumns(Long id, boolean isCheckedInColumn) {
    Map<String, Object> params = new HashMap<>();
    params.put("funnelId", id);

    ArrayList<FunnelColumn> allColumns = new ArrayList<>();
    allColumns.add(new FunnelColumn(27L, "Owner", "owner_name", 0L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(28L, "Office", "office", 1L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(29L, "State", "state",2L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(30L, "Metro", "metro_area", 3L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(31L, "Status", "status_type", 4L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(32L, "Project Name", "project_name", 5L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(33L, "Project ID", "project_id", 6L, DataType.INTEGER.getId(), DataType.INTEGER.getDataType()));
    allColumns.add(new FunnelColumn(34L, "Source", "source_name", 8L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(35L, "System Size", "system_size", 9L, DataType.NUMERIC.getId(), DataType.NUMERIC.getDataType()));
    allColumns.add(new FunnelColumn(36L, "Financier", "financier", 10L, DataType.TEXT.getId(), DataType.TEXT.getDataType()));
    allColumns.add(new FunnelColumn(37L, "Appointment Date", "appointment_date", 11L, DataType.TIMESTAMP.getId(), DataType.TIMESTAMP.getDataType()));
    allColumns.add(new FunnelColumn(38L, "Cancelled Date", "cancelled_date", 12L, DataType.TIMESTAMP.getId(), DataType.TIMESTAMP.getDataType()));
    if (isCheckedInColumn) {
      // checked in column should always be last
      allColumns.add(new FunnelColumn(39L, "Checked In Time", "checked_in_time", 25L, DataType.TIMESTAMP.getId(), DataType.TIMESTAMP.getDataType()));
    }

    List<FunnelColumn> results = sqlCache.queryBySql(CloserDashboardQuery.getFunnelColumns, params, FunnelColumn.class);
    allColumns.addAll(results);
    return allColumns;
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

}
