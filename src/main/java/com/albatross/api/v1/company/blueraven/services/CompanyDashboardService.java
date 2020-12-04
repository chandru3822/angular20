package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CompanyDashboardDrillData;
import com.albatross.api.v1.company.blueraven.models.CompanyDashboardTargets;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.Maps;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.Month;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
@Slf4j
public class CompanyDashboardService {
    @Autowired
    private NamedParameterJdbcTemplate jdbc;

    @Autowired
    private SqlCache sqlCache;

    @Autowired
    private SecurityService securityService;

    // Used to keep track of the week the feature was released and the first week values are kept for
    private LocalDate startOfTrackingDate = LocalDate.of(2019, Month.NOVEMBER, 25);

    private final String MILESTONE = "milestone";
    private final String ACTUAL_TOTAL = "actualTotal";
    private final String ACTUAL_BRS = "actualBrs";
    private final String ACTUAL_PARTNER = "actualPartner";
    private final String PLANNED_TOTAL = "plannedTotal";
    private final String PLANNED_BRS = "plannedBrs";
    private final String PLANNED_PARTNER = "plannedPartner";
    private final String TOTAL = "Total";
    private final String BRS = "BRS";
    private final String PARTNER = "Partner";

    public List<CompanyDashboardTargets> getTargets() {
        populateDates();

        return sqlCache.query("dash.getTargets", null, CompanyDashboardTargets.class);
    }

    public String getWeekTargets(java.sql.Date targetDate) {
        String sql = " SELECT array_to_json(array_agg(row_to_json(targets))) " +
                "      FROM ( " +
                "       SELECT * FROM brs.company_dashboard_targets " +
                "       where target_date = :targetDate" +
                "     ) targets ";
        HashMap<String, Object> params = new HashMap<>();
        params.put("targetDate", targetDate);
        return jdbc.queryForObject(sql, params, String.class);
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
        String getDatesSql = " SELECT array_to_json(array_agg(row_to_json(dates))) " +
                "      FROM ( " +
                "       SELECT target_date FROM brs.company_dashboard_targets ORDER BY target_date ASC "+
                "     ) dates ";
        String existingDates = jdbc.queryForObject(getDatesSql, Maps.newHashMap(), String.class);
        LocalDate currentTrackDate = startOfTrackingDate;
        // Check to see if any Monday is missing from the starting Date (11/25/19) until next week's Monday
        while (currentTrackDate.isBefore(nextMonday) || currentTrackDate.isEqual(nextMonday)) {
            String dateToAdd = dateFormat.format(currentTrackDate);
            // If the date is not in the DB, insert it
            if (existingDates == null || !existingDates.contains(dateToAdd)) {
                HashMap<String, Object> params = new HashMap<>();
                String prevTargets = getWeekTargets(java.sql.Date.valueOf(currentTrackDate.minusWeeks(1)));
                JSONObject latestTargetsJson = new JSONObject(prevTargets.substring(1, prevTargets.length()-1));
                params.put("bookingsBrs", latestTargetsJson.isNull("bookings_brs") ? null : latestTargetsJson.get("bookings_brs"));
                params.put("bookingsPartner", latestTargetsJson.isNull("bookings_partner") ? null : latestTargetsJson.get("bookings_partner"));
                params.put("finalDesignsApprovedBrs", latestTargetsJson.isNull("final_designs_approved_brs") ? null : latestTargetsJson.get("final_designs_approved_brs"));
                params.put("finalDesignsApprovedPartner", latestTargetsJson.isNull("final_designs_approved_partner") ? null : latestTargetsJson.get("final_designs_approved_partner"));
                params.put("substantialCompletionsBrs", latestTargetsJson.isNull("substantial_completions_brs") ? null : latestTargetsJson.get("substantial_completions_brs"));
                params.put("substantialCompletionsPartner", latestTargetsJson.isNull("substantial_completions_partner") ? null : latestTargetsJson.get("substantial_completions_partner"));
                params.put("finalCompletionsBrs", latestTargetsJson.isNull("final_completions_partner") ? null : latestTargetsJson.get("final_completions_brs"));
                params.put("finalCompletionsPartner", latestTargetsJson.isNull("final_completions_partner") ? null : latestTargetsJson.get("final_completions_partner"));
                params.put("targetDate", java.sql.Date.valueOf(currentTrackDate));
                jdbc.update(sqlCache.getByKey("dash.insertTargets"), new MapSqlParameterSource(params));
            }
            currentTrackDate = currentTrackDate.plusWeeks(1);
        }
    }

    public void updateTargets(List<CompanyDashboardTargets> targetValueRows) {
        for (CompanyDashboardTargets targetValueRow: targetValueRows) {
            HashMap<String, Object> params = new HashMap<>();
            params.put("id", targetValueRow.getId());
            params.put("bookingsBrs", targetValueRow.getBookingsBrs());
            params.put("bookingsPartner", targetValueRow.getBookingsPartner());
            params.put("finalDesignsApprovedBrs", targetValueRow.getFinalDesignsApprovedBrs());
            params.put("finalDesignsApprovedPartner", targetValueRow.getFinalDesignsApprovedPartner());
            params.put("substantialCompletionsBrs", targetValueRow.getSubstantialCompletionsBrs());
            params.put("substantialCompletionsPartner", targetValueRow.getSubstantialCompletionsPartner());
            params.put("finalCompletionsBrs", targetValueRow.getFinalCompletionsBrs());
            params.put("finalCompletionsPartner", targetValueRow.getFinalCompletionsPartner());

            jdbc.update(sqlCache.getByKey("dash.updateTargets"), params);
        }
    }

    public String getDashboardValues(String startDateIn, String endDateIn) {
        HashMap<String, Double> plannedValuesMap = initPlannedValuesMap();

        User user = securityService.getCurrentUser();
        boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

        if (isParent) {
            LocalDate startLocalDate = LocalDate.parse(startDateIn);
            LocalDate endLocalDate = LocalDate.parse(endDateIn);
            LocalDate thisWeeksMonday = LocalDate.now().with(DayOfWeek.MONDAY);
            // If the end date is set to a date that is past the current weeks monday
            // Set it to this weeks monday, since we only record data up to the current week
            if (endLocalDate.isAfter(thisWeeksMonday)) {
                endLocalDate = thisWeeksMonday;
            }

            // If the start date is after the end date, make the dates the same
            if (startLocalDate.isAfter(endLocalDate)) {
                startLocalDate = endLocalDate;
            }
            else if (startLocalDate.isBefore(startOfTrackingDate)) {
                // If the start date is before the start of tracking date, use the start of tracking date
                startLocalDate = startOfTrackingDate;
            }

            long totalNumDays = ChronoUnit.DAYS.between(startLocalDate, endLocalDate);
            long daysToIterate = ChronoUnit.DAYS.between(startLocalDate, endLocalDate);

            LocalDate currentMonday = startLocalDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            LocalDate endDateMonday = endLocalDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

            HashMap<String, Object> plannedValuesParams = new HashMap<>();
            plannedValuesParams.put("startDate", java.sql.Date.valueOf(currentMonday));
            plannedValuesParams.put("endDate", java.sql.Date.valueOf(endDateMonday));

            List<CompanyDashboardTargets> plannedValues = sqlCache.query("dash.getPlannedValues", plannedValuesParams, CompanyDashboardTargets.class);

            HashMap<LocalDate, Double> dateWeightsMap = new HashMap<>();

            // If date range is covered under a single week
            if (currentMonday.isEqual(endDateMonday)) {
                dateWeightsMap.put(currentMonday, 1.0);
            }
            else {
                LocalDate currentDay = startLocalDate;
                // Calculate the weight for each week in the given range based on the days
                while (currentMonday.isBefore(endDateMonday) || currentMonday.isEqual(endDateMonday)) {
                    LocalDate upcomingMonday = currentMonday.with(TemporalAdjusters.next(DayOfWeek.MONDAY));
                    long daysWeight = ChronoUnit.DAYS.between(currentDay, upcomingMonday);
                    // Used to handle case of End Date being before the upcoming Monday
                    if (daysWeight >= daysToIterate) {
                        daysWeight = daysToIterate;
                    }

                    daysToIterate -= daysWeight;
                    dateWeightsMap.put(currentMonday, ((double)daysWeight/totalNumDays));
                    currentDay = currentDay.with(TemporalAdjusters.next(DayOfWeek.MONDAY));
                    currentMonday = currentMonday.with(TemporalAdjusters.next(DayOfWeek.MONDAY));
                }
            }

            // For each week, get the Planned values and put them in the plannedValuesMap using the corresponding weight value
            for (CompanyDashboardTargets row : plannedValues) {
                try {
                    LocalDate currentWeek = LocalDate.ofInstant(row.getTargetDate().toInstant(), ZoneId.systemDefault());
                    Double currentWeight = dateWeightsMap.get(currentWeek);

                    plannedValuesMap.put("bookingsBrs", plannedValuesMap.get("bookingsBrs") + row.getBookingsBrs() *currentWeight);
                    plannedValuesMap.put("bookingsPartner", plannedValuesMap.get("bookingsPartner") + row.getBookingsPartner() *currentWeight);
                    plannedValuesMap.put("finalDesignsApprovedBrs", plannedValuesMap.get("finalDesignsApprovedBrs") + row.getFinalDesignsApprovedBrs() *currentWeight);
                    plannedValuesMap.put("finalDesignsApprovedPartner", plannedValuesMap.get("finalDesignsApprovedPartner") + row.getFinalDesignsApprovedPartner() *currentWeight);
                    plannedValuesMap.put("substantialCompletionsBrs", plannedValuesMap.get("substantialCompletionsBrs") + row.getSubstantialCompletionsBrs() *currentWeight);
                    plannedValuesMap.put("substantialCompletionsPartner", plannedValuesMap.get("substantialCompletionsPartner") + row.getSubstantialCompletionsPartner() *currentWeight);
                    plannedValuesMap.put("finalCompletionsBrs", plannedValuesMap.get("finalCompletionsBrs") + row.getFinalCompletionsBrs() *currentWeight);
                    plannedValuesMap.put("finalCompletionsPartner", plannedValuesMap.get("finalCompletionsPartner") + row.getFinalCompletionsPartner() *currentWeight);
                } catch (Exception e) {
                    log.error("COMPANY DASH: error {}", e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }
        }

        // Used to store an array of the values displayed on the Company Dashboard table
        JSONArray dashValues = new JSONArray();
        HashMap<String, Object> params = new HashMap<>();
        params.put("startDate", startDateIn);
        params.put("endDate", endDateIn);
        params.put("isParent", isParent);
        params.put("companyId", user.getCompanyId());
        params.put("parentCompanyId", user.getHighestParentCompanyId());

        // Appointments Created
        JSONObject apptCreatedValues = new JSONObject();
        apptCreatedValues.put(MILESTONE, "Appointments Created");
        apptCreatedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getAppointmentsCreatedActualTotal", params));

        if (isParent) {
            apptCreatedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getAppointmentsCreatedActualBrs", params));
            apptCreatedValues.put(ACTUAL_PARTNER, "-");
            apptCreatedValues.put(PLANNED_TOTAL, "-");
            apptCreatedValues.put(PLANNED_BRS, "-");
            apptCreatedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(apptCreatedValues);
        }
        dashValues.put(apptCreatedValues);

        // Planned Appointments
        JSONObject plannedApptsValues = new JSONObject();
        plannedApptsValues.put(MILESTONE, "Planned Appointments");
        plannedApptsValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getPlannedAppointmentsActualTotal", params));

        if (isParent) {
            plannedApptsValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getPlannedAppointmentsActualBrs", params));
            plannedApptsValues.put(ACTUAL_PARTNER, "-");
            plannedApptsValues.put(PLANNED_TOTAL, "-");
            plannedApptsValues.put(PLANNED_BRS, "-");
            plannedApptsValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(plannedApptsValues);
        }
        dashValues.put(plannedApptsValues);

        // Pitches
        JSONObject pitchesValues = new JSONObject();
        pitchesValues.put(MILESTONE, "Pitches");
        pitchesValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getPitchedActualTotal", params));

        if (isParent) {
            pitchesValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getPitchedActualBrs", params));
            pitchesValues.put(ACTUAL_PARTNER, "-");
            pitchesValues.put(PLANNED_TOTAL, "-");
            pitchesValues.put(PLANNED_BRS, "-");
            pitchesValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(pitchesValues);
        }
        dashValues.put(pitchesValues);

        // Bookings
        JSONObject bookingsValues = new JSONObject();
        bookingsValues.put(MILESTONE, "Bookings");
        bookingsValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getBookingsActualTotal", params));

        if (isParent) {
            bookingsValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getBookingsActualBrs", params));
            bookingsValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getBookingsActualPartner", params));
            bookingsValues.put(PLANNED_TOTAL, Math.round(plannedValuesMap.get("bookingsBrs") + plannedValuesMap.get("bookingsPartner")));
            bookingsValues.put(PLANNED_BRS, Math.round(plannedValuesMap.get("bookingsBrs")));
            bookingsValues.put(PLANNED_PARTNER, Math.round(plannedValuesMap.get("bookingsPartner")));
            addDifferenceValues(bookingsValues);
        }
        dashValues.put(bookingsValues);

        // Site Surveys Verified
        JSONObject siteSurveysVerifiedValues = new JSONObject();
        siteSurveysVerifiedValues.put(MILESTONE, "Site Surveys Verified");
        siteSurveysVerifiedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getSiteSurveysVerifiedActualTotal", params));

        if (isParent) {
            siteSurveysVerifiedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getSiteSurveysVerifiedActualBrs", params));
            siteSurveysVerifiedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getSiteSurveysVerifiedActualPartner", params));
            siteSurveysVerifiedValues.put(PLANNED_TOTAL, "-");
            siteSurveysVerifiedValues.put(PLANNED_BRS, "-");
            siteSurveysVerifiedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(siteSurveysVerifiedValues);
        }
        dashValues.put(siteSurveysVerifiedValues);

        // Final Designs QA'd
        JSONObject finalDesignsQadValues = new JSONObject();
        finalDesignsQadValues.put(MILESTONE, "Final Designs QA'd");
        finalDesignsQadValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getFinalDesignsQadActualTotal", params));

        if (isParent) {
            finalDesignsQadValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getFinalDesignsQadActualBrs", params));
            finalDesignsQadValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getFinalDesignsQadActualPartner", params));
            finalDesignsQadValues.put(PLANNED_TOTAL, "-");
            finalDesignsQadValues.put(PLANNED_BRS, "-");
            finalDesignsQadValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(finalDesignsQadValues);
        }
        dashValues.put(finalDesignsQadValues);

        // Final Designs Sent
        JSONObject finalDesignsSentValues = new JSONObject();
        finalDesignsSentValues.put(MILESTONE, "Final Designs Sent");
        finalDesignsSentValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getFinalDesignsSentActualTotal", params));

        if (isParent) {
            finalDesignsSentValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getFinalDesignsSentActualBrs", params));
            finalDesignsSentValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getFinalDesignsSentActualPartner", params));
            finalDesignsSentValues.put(PLANNED_TOTAL, "-");
            finalDesignsSentValues.put(PLANNED_BRS, "-");
            finalDesignsSentValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(finalDesignsSentValues);
        }
        dashValues.put(finalDesignsSentValues);

        // Final Designs Approved
        JSONObject finalDesignsApprovedValues = new JSONObject();
        finalDesignsApprovedValues.put(MILESTONE, "Final Designs Approved");
        finalDesignsApprovedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getFinalDesignsApprovedActualTotal", params));

        if (isParent) {
            finalDesignsApprovedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getFinalDesignsApprovedActualBrs", params));
            finalDesignsApprovedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getFinalDesignsApprovedActualPartner", params));
            finalDesignsApprovedValues.put(PLANNED_TOTAL, Math.round(plannedValuesMap.get("finalDesignsApprovedBrs") + plannedValuesMap.get("finalDesignsApprovedPartner")));
            finalDesignsApprovedValues.put(PLANNED_BRS, Math.round(plannedValuesMap.get("finalDesignsApprovedBrs")));
            finalDesignsApprovedValues.put(PLANNED_PARTNER, Math.round(plannedValuesMap.get("finalDesignsApprovedPartner")));
            addDifferenceValues(finalDesignsApprovedValues);
        }
        dashValues.put(finalDesignsApprovedValues);

        // Plan Sets Created
        JSONObject planSetsCreatedValues = new JSONObject();
        planSetsCreatedValues.put(MILESTONE, "Plan Sets Created");
        planSetsCreatedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getPlanSetsCreatedActualTotal", params));

        if (isParent) {
            planSetsCreatedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getPlanSetsCreatedActualBrs", params));
            planSetsCreatedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getPlanSetsCreatedActualPartner", params));
            planSetsCreatedValues.put(PLANNED_TOTAL, "-");
            planSetsCreatedValues.put(PLANNED_BRS, "-");
            planSetsCreatedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(planSetsCreatedValues);
        }
        dashValues.put(planSetsCreatedValues);

        // Permit Packs Created
        JSONObject permitPacksCreatedValues = new JSONObject();
        permitPacksCreatedValues.put(MILESTONE, "Permit Packs Created");
        permitPacksCreatedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getPermitPacksCreatedActualTotal", params));

        if (isParent) {
            permitPacksCreatedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getPermitPacksCreatedActualBrs", params));
            permitPacksCreatedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getPermitPacksCreatedActualPartner", params));
            permitPacksCreatedValues.put(PLANNED_TOTAL, "-");
            permitPacksCreatedValues.put(PLANNED_BRS, "-");
            permitPacksCreatedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(permitPacksCreatedValues);
        }
        dashValues.put(permitPacksCreatedValues);

        // Permits Submitted
        JSONObject permitsSubmittedValues = new JSONObject();
        permitsSubmittedValues.put(MILESTONE, "Permits Submitted");
        permitsSubmittedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getPermitsSubmittedActualTotal", params));

        if (isParent) {
            permitsSubmittedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getPermitsSubmittedActualBrs", params));
            permitsSubmittedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getPermitsSubmittedActualPartner", params));
            permitsSubmittedValues.put(PLANNED_TOTAL, "-");
            permitsSubmittedValues.put(PLANNED_BRS, "-");
            permitsSubmittedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(permitsSubmittedValues);
        }
        dashValues.put(permitsSubmittedValues);

        // Permits Approved
        JSONObject permitsApprovedValues = new JSONObject();
        permitsApprovedValues.put(MILESTONE, "Permits Approved");
        permitsApprovedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getPermitsApprovedActualTotal", params));

        if (isParent) {
            permitsApprovedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getPermitsApprovedActualBrs", params));
            permitsApprovedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getPermitsApprovedActualPartner", params));
            permitsApprovedValues.put(PLANNED_TOTAL, "-");
            permitsApprovedValues.put(PLANNED_BRS, "-");
            permitsApprovedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(permitsApprovedValues);
        }
        dashValues.put(permitsApprovedValues);

        // Installations Scheduled
        JSONObject installSchedValues = new JSONObject();
        installSchedValues.put(MILESTONE, "Installations Scheduled");
        installSchedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getInstallationsScheduledActualTotal", params));

        if (isParent) {
            installSchedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getInstallationsScheduledActualBrs", params));
            installSchedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getInstallationsScheduledActualPartner", params));
            installSchedValues.put(PLANNED_TOTAL, "-");
            installSchedValues.put(PLANNED_BRS, "-");
            installSchedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(installSchedValues);
        }
        dashValues.put(installSchedValues);

        // Planned Installations
        JSONObject plannedInstallValues = new JSONObject();
        plannedInstallValues.put(MILESTONE, "Planned Installations");
        plannedInstallValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getPlannedInstallationsActualTotal", params));

        if (isParent) {
            plannedInstallValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getPlannedInstallationsActualBrs", params));
            plannedInstallValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getPlannedInstallationsActualPartner", params));
            plannedInstallValues.put(PLANNED_TOTAL, "-");
            plannedInstallValues.put(PLANNED_BRS, "-");
            plannedInstallValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(plannedInstallValues);
        }
        dashValues.put(plannedInstallValues);

        // Substantial Completions
        JSONObject substantialCompletionsValues = new JSONObject();
        substantialCompletionsValues.put(MILESTONE, "Substantial Completions");
        substantialCompletionsValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getSubstantialCompletionsActualTotal", params));

        if (isParent) {
            substantialCompletionsValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getSubstantialCompletionsActualBrs", params));
            substantialCompletionsValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getSubstantialCompletionsActualPartner", params));
            substantialCompletionsValues.put(PLANNED_TOTAL, Math.round(plannedValuesMap.get("substantialCompletionsBrs") + plannedValuesMap.get("substantialCompletionsPartner")));
            substantialCompletionsValues.put(PLANNED_BRS, Math.round(plannedValuesMap.get("substantialCompletionsBrs")));
            substantialCompletionsValues.put(PLANNED_PARTNER, Math.round(plannedValuesMap.get("substantialCompletionsPartner")));
            addDifferenceValues(substantialCompletionsValues);
        }
        dashValues.put(substantialCompletionsValues);

        // Inspections Scheduled
        JSONObject inspectionsSchedValues = new JSONObject();
        inspectionsSchedValues.put(MILESTONE, "Inspections Scheduled");
        inspectionsSchedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getInspectionsScheduledActualTotal", params));

        if (isParent) {
            inspectionsSchedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getInspectionsScheduledActualBrs", params));
            inspectionsSchedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getInspectionsScheduledActualPartner", params));
            inspectionsSchedValues.put(PLANNED_TOTAL, "-");
            inspectionsSchedValues.put(PLANNED_BRS, "-");
            inspectionsSchedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(inspectionsSchedValues);
        }
        dashValues.put(inspectionsSchedValues);

        // Planned Inspections
        JSONObject plannedInspectionValues = new JSONObject();
        plannedInspectionValues.put(MILESTONE, "Planned Inspections");
        plannedInspectionValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getPlannedInspectionsActualTotal", params));

        if (isParent) {
            plannedInspectionValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getPlannedInspectionsActualBrs", params));
            plannedInspectionValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getPlannedInspectionsActualPartner", params));
            plannedInspectionValues.put(PLANNED_TOTAL, "-");
            plannedInspectionValues.put(PLANNED_BRS, "-");
            plannedInspectionValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(plannedInspectionValues);
        }
        dashValues.put(plannedInspectionValues);

        // Inspections Passed
        JSONObject inspectionsPassedValues = new JSONObject();
        inspectionsPassedValues.put(MILESTONE, "Inspections Passed");
        inspectionsPassedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getInspectionsPassedActualTotal", params));

        if (isParent) {
            inspectionsPassedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getInspectionsPassedActualBrs", params));
            inspectionsPassedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getInspectionsPassedActualPartner", params));
            inspectionsPassedValues.put(PLANNED_TOTAL, "-");
            inspectionsPassedValues.put(PLANNED_BRS, "-");
            inspectionsPassedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(inspectionsPassedValues);
        }
        dashValues.put(inspectionsPassedValues);

        // Inspection Results Submitted
        JSONObject inspectionsSubmittedValues = new JSONObject();
        inspectionsSubmittedValues.put(MILESTONE, "Inspection Results Submitted");
        inspectionsSubmittedValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getInspectionResultsSubmittedActualTotal", params));

        if (isParent) {
            inspectionsSubmittedValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getInspectionResultsSubmittedActualBrs", params));
            inspectionsSubmittedValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getInspectionResultsSubmittedActualPartner", params));
            inspectionsSubmittedValues.put(PLANNED_TOTAL, "-");
            inspectionsSubmittedValues.put(PLANNED_BRS, "-");
            inspectionsSubmittedValues.put(PLANNED_PARTNER, "-");
            addDifferenceValues(inspectionsSubmittedValues);
        }
        dashValues.put(inspectionsSubmittedValues);

        // Final Completions
        JSONObject finalCompletionsValues = new JSONObject();
        finalCompletionsValues.put(MILESTONE, "Final Completions");
        finalCompletionsValues.put(ACTUAL_TOTAL, getValueFromSqlKey("dash.getFinalCompletionsActualTotal", params));

        if (isParent) {
            finalCompletionsValues.put(ACTUAL_BRS, getValueFromSqlKey("dash.getFinalCompletionsActualBrs", params));
            finalCompletionsValues.put(ACTUAL_PARTNER, getValueFromSqlKey("dash.getFinalCompletionsActualPartner", params));
            finalCompletionsValues.put(PLANNED_TOTAL, Math.round(plannedValuesMap.get("finalCompletionsBrs") + plannedValuesMap.get("finalCompletionsPartner")));
            finalCompletionsValues.put(PLANNED_BRS, Math.round(plannedValuesMap.get("finalCompletionsBrs")));
            finalCompletionsValues.put(PLANNED_PARTNER, Math.round(plannedValuesMap.get("finalCompletionsPartner")));
            addDifferenceValues(finalCompletionsValues);
        }
        dashValues.put(finalCompletionsValues);

        return dashValues.toString();
    }

    public List<CompanyDashboardDrillData> getDrilldownData(String startDateIn, String endDateIn, String milestone, String column) {
        User user = securityService.getCurrentUser();
        boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

        String sql = getDrilldownSqlQuery(milestone, column);
        HashMap<String, Object> params = new HashMap<>();
        params.put("startDate", java.sql.Date.valueOf(startDateIn));
        params.put("endDate", java.sql.Date.valueOf(endDateIn));
        params.put("isParent", isParent);
        params.put("companyId", user.getCompanyId());
        params.put("parentCompanyId", user.getHighestParentCompanyId());

        return sqlCache.query(sql, params, CompanyDashboardDrillData.class);
    }

    private int getValueFromSqlKey(String sqlKey, HashMap<String, Object> params) {
        Optional<String> results = sqlCache.get(sqlKey, params, new SingleColumnRowMapper<>(String.class));
        return Integer.parseInt(results.orElse("0"));
    }

    private String getDrilldownSqlQuery(String milestone, String column) {
        String sql = "";
        if (milestone.equals("Appointments Created")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getAppointmentsCreatedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getAppointmentsCreatedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getAppointmentsCreatedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Planned Appointments")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getPlannedAppointmentsActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getPlannedAppointmentsActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getPlannedAppointmentsActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Pitches")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getPitchedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getPitchedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getPitchedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Bookings")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getBookingsActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getBookingsActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getBookingsActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Site Surveys Verified")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getSiteSurveysVerifiedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getSiteSurveysVerifiedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getSiteSurveysVerifiedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Final Designs QA'd")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getFinalDesignsQadActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getFinalDesignsQadActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getFinalDesignsQadActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Final Designs Sent")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getFinalDesignsSentActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getFinalDesignsSentActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getFinalDesignsSentActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Final Designs Approved")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getFinalDesignsApprovedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getFinalDesignsApprovedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getFinalDesignsApprovedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Plan Sets Created")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getPlanSetsCreatedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getPlanSetsCreatedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getPlanSetsCreatedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Permit Packs Created")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getPermitPacksCreatedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getPermitPacksCreatedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getPermitPacksCreatedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Permits Submitted")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getPermitsSubmittedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getPermitsSubmittedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getPermitsSubmittedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Permits Approved")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getPermitsApprovedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getPermitsApprovedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getPermitsApprovedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Installations Scheduled")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getInstallationsScheduledActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getInstallationsScheduledActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getInstallationsScheduledActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Planned Installations")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getPlannedInstallationsActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getPlannedInstallationsActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getPlannedInstallationsActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Substantial Completions")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getSubstantialCompletionsActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getSubstantialCompletionsActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getSubstantialCompletionsActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Inspections Scheduled")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getInspectionsScheduledActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getInspectionsScheduledActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getInspectionsScheduledActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Planned Inspections")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getPlannedInspectionsActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getPlannedInspectionsActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getPlannedInspectionsActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Inspections Passed")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getInspectionsPassedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getInspectionsPassedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getInspectionsPassedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Inspection Results Submitted")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getInspectionResultsSubmittedActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getInspectionResultsSubmittedActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getInspectionResultsSubmittedActualPartnerDrilldown";
            }
        }
        else if (milestone.equals("Final Completions")) {
            if (column.equals(TOTAL)) {
                sql = "dash.getFinalCompletionsActualTotalDrilldown";
            }
            else if (column.equals(BRS)) {
                sql = "dash.getFinalCompletionsActualBrsDrilldown";
            }
            else if (column.equals(PARTNER)) {
                sql = "dash.getFinalCompletionsActualPartnerDrilldown";
            }
        }

        return sql;
    }

    private void addDifferenceValues(JSONObject milestoneJson) {
        if (milestoneJson.get(PLANNED_TOTAL) == "-") {
            milestoneJson.put("differenceTotal", "-");
            milestoneJson.put("differenceBrs", "-");
        } else {
            milestoneJson.put("differenceTotal", milestoneJson.getInt(ACTUAL_TOTAL) - milestoneJson.getInt(PLANNED_TOTAL));
            milestoneJson.put("differenceBrs", milestoneJson.getInt(ACTUAL_BRS) - milestoneJson.getInt(PLANNED_BRS));
        }

        if (!milestoneJson.getString("milestone").equals("Bookings") && !milestoneJson.getString("milestone").equals("Final Designs Approved") && !milestoneJson.getString("milestone").equals("Substantial Completions") && !milestoneJson.getString("milestone").equals("Final Completions")) {
            milestoneJson.put("differencePartner", "-");
        } else {
            milestoneJson.put("differencePartner", milestoneJson.getInt(ACTUAL_PARTNER) - milestoneJson.getInt(PLANNED_PARTNER));
        }
    }

    private HashMap<String, Double> initPlannedValuesMap() {
        return new HashMap<>() {{
            put("appointmentCreatedBrs", 0.0);
            put("appointmentCreatedPartner", 0.0);
            put("plannedAppointmentsBrs", 0.0);
            put("plannedAppointmentsPartner", 0.0);
            put("pitchesBrs", 0.0);
            put("pitchesPartner", 0.0);
            put("bookingsBrs", 0.0);
            put("bookingsPartner", 0.0);
            put("siteSurveysVerifiedBrs", 0.0);
            put("siteSurveysVerifiedPartner", 0.0);
            put("finalDesignsQadBrs", 0.0);
            put("finalDesignsQadPartner", 0.0);
            put("finalDesignsSentBrs", 0.0);
            put("finalDesignsSentPartner", 0.0);
            put("finalDesignsApprovedBrs", 0.0);
            put("finalDesignsApprovedPartner", 0.0);
            put("planSetsCreatedBrs", 0.0);
            put("planSetsCreatedPartner", 0.0);
            put("permitPacksCreatedBrs", 0.0);
            put("permitPacksCreatedPartner", 0.0);
            put("permitsSubmittedBrs", 0.0);
            put("permitsSubmittedPartner", 0.0);
            put("permitsApprovedBrs", 0.0);
            put("permitsApprovedPartner", 0.0);
            put("installationsScheduledBrs", 0.0);
            put("installationsScheduledPartner", 0.0);
            put("plannedInstallationsBrs", 0.0);
            put("plannedInstallationsPartner", 0.0);
            put("substantialCompletionsBrs", 0.0);
            put("substantialCompletionsPartner", 0.0);
            put("inspectionsScheduledBrs", 0.0);
            put("inspectionsScheduledPartner", 0.0);
            put("plannedInspectionsBrs", 0.0);
            put("plannedInspectionsPartner", 0.0);
            put("inspectionsPassedBrs", 0.0);
            put("inspectionsPassedPartner", 0.0);
            put("inspectionsSubmittedBrs", 0.0);
            put("inspectionsSubmittedPartner", 0.0);
            put("finalCompletionsBrs", 0.0);
            put("finalCompletionsPartner", 0.0);
        }};
    }
}
