package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CompanyDashboardDateRange;
import com.albatross.api.v1.company.blueraven.models.CompanyDashboardTargets;
import com.albatross.api.v1.company.blueraven.models.CompanyPeriod;
import com.albatross.api.v1.company.blueraven.models.Triumvirate;
import com.albatross.api.v1.company.blueraven.services.queries.CompanyDashboardQuery;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.ProjectQuery;
import com.google.common.collect.Maps;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.cglib.core.Local;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.*;

import static java.time.temporal.TemporalAdjusters.*;

@Slf4j
@Service
@RequiredArgsConstructor
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

  public String getDashboardValues(String startDate, String endDate, String trendStart, String trendEnd) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("trendStart", trendStart);
    params.put("trendEnd", trendEnd);

      return sqlCache.queryForObjectBySql(CompanyDashboardQuery.getCompanyDashboard, params, String.class);
  }

  public String getDrilldownValues(String startDate, String endDate, Long milestoneTypeId) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("milestoneTypeId", milestoneTypeId);

    String results = sqlCache.queryForObjectBySql(CompanyDashboardQuery.getCompanyDashboardDrilldown, params, String.class);

    return results;
  }

  public List<String> getDrilldownHeaders(Long milestoneTypeId){
    HashMap<String, Object> params = new HashMap<>();
    params.put("milestoneTypeId", milestoneTypeId);

    return sqlCache.queryBySql(CompanyDashboardQuery.getCompanyDashboardDrilldownHeaders, params, new SingleColumnRowMapper<>(String.class));

  }

//  public ArrayList<CompanyDashboardDateRange> getDropdownValues(Instant today) {
//    User user = securityService.getCurrentUser();
//
//    ArrayList<CompanyDashboardDateRange> ranges = new ArrayList<>();
//    HashMap<String, Object> params = new HashMap<>();
//    params.put("today", today.toString());
//    List<CompanyPeriod> companyPeriods = sqlCache.queryBySql(CompanyDashboardQuery.getCompanyDashboardPeriods, params, CompanyPeriod.class);
//    CompanyPeriod currentPeriod = null;
//    CompanyPeriod previousPeriod = null;
//    CompanyPeriod doublePreviousPeriod = null;
//    for(int x = 0; x < companyPeriods.size(); x++){
//      if(LocalDateTime.ofInstant(today, ZoneId.of("UTC")).truncatedTo(ChronoUnit.DAYS).isBefore(LocalDateTime.ofInstant(companyPeriods.get(x).getEndDate().toInstant(), ZoneId.of("UTC")))
//        || LocalDateTime.ofInstant(today, ZoneId.of("UTC")).truncatedTo(ChronoUnit.DAYS).equals(LocalDateTime.ofInstant(companyPeriods.get(x).getEndDate().toInstant(), ZoneId.of("UTC")))){
//        currentPeriod = companyPeriods.get(x);
//        previousPeriod = companyPeriods.get(x-1);
//        doublePreviousPeriod = companyPeriods.get(x-2);
//      }
//    }
//    String[] rangeNames = {"Yesterday", "Today", "Tomorrow", "Current Week", "Current Period", "Last Week",
//    "Last 30 Days", "Last Period", "Period", "Custom", "Current Month", "Current Quarter", "Current Year",
//    "All Time"};
//
//    Instant lastMonthEnd = today.minus(today.atZone(ZoneId.of("UTC")).getDayOfMonth(), ChronoUnit.DAYS);
//    Instant lastMonthStart = lastMonthEnd.minus(lastMonthEnd.atZone(ZoneId.of("UTC")).getDayOfMonth()-1, ChronoUnit.DAYS);
//
//    Instant currentQuarterStart = today;
//    Instant currentQuarterEnd = today;
//    Instant currentMonthEnd = today;
//    Instant currentYearStart = today.minus(today.atZone(ZoneId.of("UTC")).getDayOfYear()-1, ChronoUnit.DAYS);
//    Instant currentYearEnd = currentYearStart.plus(364, ChronoUnit.DAYS);
//
//    //Its a leap year
//    if(currentYearEnd.plus(1, ChronoUnit.DAYS).atZone(ZoneId.of("UTC")).getYear() == currentYearStart.atZone(ZoneId.of("UTC")).getYear()){
//      currentYearEnd = currentYearEnd.plus(1, ChronoUnit.DAYS);
//    }
//
//    while((currentQuarterStart.atZone(ZoneId.of("UTC")).getMonth().getValue()-1)%3 != 0){
//      currentQuarterStart.minus((currentQuarterStart.atZone(ZoneId.of("UTC")).getDayOfMonth()), ChronoUnit.DAYS);
//    }
//    currentQuarterStart = currentQuarterStart.minus(currentQuarterStart.atZone(ZoneId.of("UTC")).getDayOfMonth()-1, ChronoUnit.DAYS);
//
//    while((currentQuarterEnd.atZone(ZoneId.of("UTC")).getMonth().getValue())%3 != 0) {
//      currentQuarterEnd = currentQuarterEnd.plus(27, ChronoUnit.DAYS);
//    }
//    while(((currentQuarterEnd.plus(1, ChronoUnit.DAYS).atZone(ZoneId.of("UTC")).getMonth().getValue()-1)%3) != 0){
//      currentQuarterEnd = currentQuarterEnd.plus(1, ChronoUnit.DAYS);
//    }
//
//    while(currentMonthEnd.plus(1, ChronoUnit.DAYS).atZone(ZoneId.of("UTC")).getMonth().getValue() == today.atZone(ZoneId.of("UTC")).getMonth().getValue()){
//      currentMonthEnd = currentMonthEnd.plus(1, ChronoUnit.DAYS);
//    }
//
//    Instant previousQuarterEnd = currentQuarterStart.minus(1, ChronoUnit.DAYS);
//    Instant previousQuarterStart = previousQuarterEnd;
//    Instant lastYearEnd = currentYearStart.minus(1, ChronoUnit.DAYS);
//    Instant lastYearStart = lastYearEnd.minus(364, ChronoUnit.DAYS);
//
//    //Its a leap year
//    if(lastYearStart.minus(1, ChronoUnit.DAYS).atZone(ZoneId.of("UTC")).getYear() ==  lastYearEnd.atZone(ZoneId.of("UTC")).getYear()){
//      lastYearStart = lastYearStart.minus(1, ChronoUnit.DAYS);
//    }
//
//    while((previousQuarterStart.atZone(ZoneId.of("UTC")).getMonth().getValue()-1)%3 != 0){
//      previousQuarterStart = previousQuarterStart.minus((previousQuarterStart.atZone(ZoneId.of("UTC")).getDayOfMonth()), ChronoUnit.DAYS);
//    }
//    previousQuarterStart = previousQuarterStart.minus(previousQuarterStart.atZone(ZoneId.of("UTC")).getDayOfMonth()-1, ChronoUnit.DAYS);
//
//
//    ranges.add(new CompanyDashboardDateRange(1, "Yesterday", "YESTERDAY", today.minus(1, ChronoUnit.DAYS), today.minus(1, ChronoUnit.DAYS), today.minus(2, ChronoUnit.DAYS), today.minus(2, ChronoUnit.DAYS), "the day before yesterday"));
//    ranges.add(new CompanyDashboardDateRange(2, "Today", "TODAY", today, today, today.minus(1, ChronoUnit.DAYS), today.minus(1, ChronoUnit.DAYS), "yesterday"));
//    ranges.add(new CompanyDashboardDateRange(3, "Tomorrow", "TOMORROW", today.plus(1, ChronoUnit.DAYS), today.plus(1, ChronoUnit.DAYS), today, today, "today"));
//    ranges.add(new CompanyDashboardDateRange(4, "Current Week", "CURRENT_WEEK", today.minus(today.atZone(ZoneId.of("UTC")).getDayOfWeek().getValue(), ChronoUnit.DAYS),
//      today.plus((7-today.atZone(ZoneId.of("UTC")).getDayOfWeek().getValue()-1), ChronoUnit.DAYS),
//      today.minus(today.atZone(ZoneId.of("UTC")).getDayOfWeek().getValue()+7, ChronoUnit.DAYS),
//      today.minus(today.atZone(ZoneId.of("UTC")).getDayOfWeek().getValue()+1, ChronoUnit.DAYS),
//      "last week"));
//    ranges.add(new CompanyDashboardDateRange(5, "Current Period", "CURRENT_PERIOD", currentPeriod.getStartDate().toInstant(), currentPeriod.getEndDate().toInstant(), previousPeriod.getStartDate().toInstant(), previousPeriod.getStartDate().toInstant(), "last period"));
//    ranges.add(new CompanyDashboardDateRange(6, "Last Week", "LAST WEEK", today.minus(6, ChronoUnit.DAYS), today, today.minus(13, ChronoUnit.DAYS), today.minus(7, ChronoUnit.DAYS), "the week before last week"));
//    ranges.add(new CompanyDashboardDateRange(7, "Last 30 Days", "LAST_30_DAYS", today.minus(29, ChronoUnit.DAYS), today, today.minus(59, ChronoUnit.DAYS), today.minus(30, ChronoUnit.DAYS), "30 days before last 30 days"));
//    ranges.add(new CompanyDashboardDateRange(8, "Last Period", "LAST_PERIOD", previousPeriod.getStartDate().toInstant(), previousPeriod.getEndDate().toInstant(), doublePreviousPeriod.getStartDate().toInstant(), doublePreviousPeriod.getEndDate().toInstant(), "the period before the last period"));
//    CompanyDashboardDateRange periodRange = new CompanyDashboardDateRange();
//    periodRange.setId(9);
//    periodRange.setPeriodList(companyPeriods.reversed());
//    periodRange.setTrendText("the period before the selected period");
//    periodRange.setFriendlyName("Period");
//    periodRange.setName("PERIOD");
//    ranges.add(periodRange);
//    ranges.add(new CompanyDashboardDateRange(10, "Custom", "CUSTOM", null, null, null, null, null));
//    ranges.add(new CompanyDashboardDateRange(11, "Current Month", "CURRENT_MONTH", today.minus(today.atZone(ZoneId.of("UTC")).getDayOfMonth()-1, ChronoUnit.DAYS), currentMonthEnd,
//      lastMonthStart, lastMonthEnd, "last month"));
//    ranges.add(new CompanyDashboardDateRange(12, "Current Quarter", "CURRENT_QUARTER", currentQuarterStart, currentQuarterEnd,
//      previousQuarterStart, previousQuarterEnd, "last quarter"));
//    ranges.add(new CompanyDashboardDateRange(13, "Current Year", "CURRENT_YEAR", currentYearStart, currentYearEnd, lastYearStart, lastYearEnd, "last year"));
//    ranges.add(new CompanyDashboardDateRange(14, "All Time", "ALL_TIME", currentYearStart, currentYearEnd, lastYearStart, lastYearEnd, "last year"));
//
//    return ranges;
//  }

  public ArrayList<CompanyDashboardDateRange> randaTesting(LocalDate today) {
    //today: if "today" is not in utc just override it here

    ArrayList<CompanyDashboardDateRange> ranges = new ArrayList<>();
    HashMap<String, Object> params = new HashMap<>();
    params.put("today", today.toString());
    List<CompanyPeriod> companyPeriods = sqlCache.queryBySql(CompanyDashboardQuery.getCompanyDashboardPeriods, params, CompanyPeriod.class);
    CompanyPeriod currentPeriod = null;
    CompanyPeriod previousPeriod = null;
    CompanyPeriod doublePreviousPeriod = null;
    Integer currentIndex = null;

    for(CompanyPeriod period : companyPeriods) {
      if( today.isBefore(period.getEndDate())){
        currentPeriod = period;
        currentIndex = companyPeriods.indexOf(period);
        previousPeriod = companyPeriods.get(currentIndex - 1);
        doublePreviousPeriod = companyPeriods.get(currentIndex - 2);
      }
    }

    YearMonth month = YearMonth.from(today);
    LocalDate currentMonthStart = month.atDay(1);
    LocalDate currentMonthEnd   = month.atEndOfMonth();
    LocalDate previousMonthStart = today.minusMonths(1).withDayOfMonth(1);
    LocalDate previousMonthEnd = currentMonthStart.minusDays(1);
    LocalDate currentYearStart = today.with(firstDayOfYear());
    LocalDate currentYearEnd = today.with(lastDayOfYear());
    LocalDate previousYearStart = currentYearEnd. plusDays(1);
    LocalDate previousYearEnd = previousYearStart.with(lastDayOfYear());


    Triumvirate triumvirate = sqlCache.queryBySql(CompanyDashboardQuery.getGetCompanyDashboardTriumvirate, params, Triumvirate.class).get(0);

    DayOfWeek weekStart = DayOfWeek.MONDAY;
    DayOfWeek weekEnd = DayOfWeek.SUNDAY;
    LocalDate currentWeekStart = today.with(previousOrSame(weekStart));
    LocalDate currentWeekEnd = today.with(nextOrSame(weekEnd));
    LocalDate lastWeekStart = currentWeekStart.minusDays(7);
    LocalDate lastWeekEnd = currentWeekEnd.minusDays(7);
    LocalDate yesterday = today.minusDays(1);
    LocalDate tomorrow = today.plusDays(1);

    ranges.add(new CompanyDashboardDateRange(1, "Yesterday", "YESTERDAY",
      yesterday,
      yesterday,
      yesterday.minusDays(1),
      yesterday.minusDays(1), "the day before yesterday"));

    ranges.add(new CompanyDashboardDateRange(2, "Today", "TODAY",
      today, today, yesterday, yesterday, "yesterday"));

    ranges.add(new CompanyDashboardDateRange(3, "Tomorrow", "TOMORROW",
      tomorrow, tomorrow, today, today, "today"));

    ranges.add(new CompanyDashboardDateRange(4, "Current Week", "CURRENT_WEEK",
      currentWeekStart,
      currentWeekEnd,
      lastWeekStart,
      lastWeekEnd,
      "last week"));

    ranges.add(new CompanyDashboardDateRange(5, "Current Period", "CURRENT_PERIOD",
      currentPeriod.getStartDate(),
      currentPeriod.getEndDate(),
      previousPeriod.getStartDate(),
      previousPeriod.getStartDate(), "last period"));

    ranges.add(new CompanyDashboardDateRange(6, "Last Week", "LAST WEEK",
      lastWeekStart,
      lastWeekEnd,
      lastWeekStart.minusDays(7),
      lastWeekEnd.minusDays(7), "the week before last week"));

    ranges.add(new CompanyDashboardDateRange(7, "Last 30 Days", "LAST_30_DAYS",
      today.minus(29, ChronoUnit.DAYS),
      today,
      today.minus(59, ChronoUnit.DAYS),
      today.minus(30, ChronoUnit.DAYS), "30 days before last 30 days"));

    ranges.add(new CompanyDashboardDateRange(8, "Last Period", "LAST_PERIOD",
      previousPeriod.getStartDate(),
      previousPeriod.getEndDate(),
      doublePreviousPeriod.getStartDate(),
      doublePreviousPeriod.getEndDate(), "the period before the selected period"));

    CompanyDashboardDateRange periodRange = new CompanyDashboardDateRange();
    periodRange.setId(9);
    periodRange.setPeriodList(companyPeriods.reversed());
    periodRange.setTrendText("the period before the selected period");
    periodRange.setFriendlyName("Period");
    periodRange.setName("PERIOD");
    ranges.add(periodRange);

    ranges.add(new CompanyDashboardDateRange(10, "Custom", "CUSTOM", null, null, null, null, null));

    ranges.add(new CompanyDashboardDateRange(11, "Current Month", "CURRENT_MONTH",
      currentMonthStart,
      currentMonthEnd,
      previousMonthStart,
      previousMonthEnd, "last month"));

    ranges.add(new CompanyDashboardDateRange(12, "Current Quarter", "CURRENT_QUARTER",
      triumvirate.getCurrentQuarterStart(),
      triumvirate.getCurrentQuarterEnd(),
      triumvirate.getLastQuarterStart(),
      triumvirate.getLastQuarterEnd(), "last quarter"));

    ranges.add(new CompanyDashboardDateRange(13, "Current Year", "CURRENT_YEAR",
      currentYearStart,
      currentYearEnd,
      previousYearStart,
      previousYearEnd, "last year"));

    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    ranges.add(new CompanyDashboardDateRange(14, "All Time", "ALL_TIME",
      LocalDate.parse("2000-01-01", formatter),
      today,
      null,
      null, null));

    return ranges;
  }
}
