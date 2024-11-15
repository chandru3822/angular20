package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.VirtualResourceCapacitySchedule;
import com.albatross.api.v1.flow.queries.CapacityQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


@Slf4j
@Service
@RequiredArgsConstructor
public class VirtualResourceCapacityService {

    private final SqlCache sqlCache;
    private final SecurityService securityService;


    public List<VirtualResourceCapacitySchedule> getCapacityForRange(Long orgId, String startTime, String endTime){
        HashMap<String, Object> params = new HashMap<>();
        params.put("orgId", orgId);
        params.put("rangeStart", startTime);
        params.put("rangeEnd", endTime);

        List<VirtualResourceCapacitySchedule> results =  sqlCache.queryBySql(
                CapacityQuery.getForRange,
                params,
                VirtualResourceCapacitySchedule.class
        );
        return null == results ? new ArrayList<VirtualResourceCapacitySchedule>() : results;
    }
    public List<VirtualResourceCapacitySchedule> getBookedForRange(Long orgId, String startTime, String endTime) {
        // Define a formatter for the input string format
        DateTimeFormatter formatter = DateTimeFormatter.ISO_OFFSET_DATE_TIME;

        // Parse the input strings into OffsetDateTime
        OffsetDateTime start = OffsetDateTime.parse(startTime, formatter);
        OffsetDateTime end = OffsetDateTime.parse(endTime, formatter);

        List<VirtualResourceCapacitySchedule> bookedForRange = new ArrayList<VirtualResourceCapacitySchedule>();
        // Loop through every half-hour interval, get the count, and add it to the bookedForRange list
        while (start.isBefore(end)) {
            VirtualResourceCapacitySchedule bookedFor30MinInterval = new VirtualResourceCapacitySchedule();
            bookedFor30MinInterval.setStartTime(start.toString());
            OffsetDateTime intervalEnd = start.plusMinutes(30);
            bookedFor30MinInterval.setEndTime(intervalEnd.toString());
            Long intervalCount = getCurrentBookedCountForCapacityScheduleRow(orgId, start.toString(), intervalEnd.toString());
            bookedFor30MinInterval.setCurrentlyBooked(intervalCount);
            bookedForRange.add(bookedFor30MinInterval);
            start = intervalEnd;
        }
        return bookedForRange;
    }

    public Long getCurrentBookedCountForCapacityScheduleRow(Long orgId, String startTime, String endTime){
        HashMap<String, Object> params = new HashMap<>();
        params.put("orgId", orgId);
        params.put("positionId", 761L);//todo: get prod position Id or pass it in with params
        params.put("startTime", startTime);
        params.put("endTime", endTime);

        return sqlCache.queryForObjectBySql(CapacityQuery.getOrgEventCount, params, Long.class);
    }

    public List<VirtualResourceCapacitySchedule> getCapacitySchedule(Long orgId, String rangeStartTime, String rangeEndTime){
        List<VirtualResourceCapacitySchedule> capacitySchedules = getCapacityForRange(orgId, rangeStartTime, rangeEndTime);
        if(capacitySchedules != null) {
            for (VirtualResourceCapacitySchedule cs : capacitySchedules) {
                cs.setCurrentlyBooked(getCurrentBookedCountForCapacityScheduleRow(orgId, cs.getStartTime(), cs.getEndTime()));
            }
            return capacitySchedules;
        }
        return null;
    }

    public void updateMaxCapacity(List<VirtualResourceCapacitySchedule> resourceCapacitySchedules){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", user.getId());
        params.put("companyId", user.getCompanyId());

        for (VirtualResourceCapacitySchedule capacity: resourceCapacitySchedules) {
            params.put("orgId", capacity.getOrgId());
            params.put("maxCapacity", capacity.getMaxCapacity());
            params.put("startTime", capacity.getStartTime());
            params.put("endTime", capacity.getEndTime());
            sqlCache.updateBySql(CapacityQuery.upsertMaxCapacity, params);
        }
    }

    public List<VirtualResourceCapacitySchedule> duplicatePreviousWeek(Long orgId, String currentWeekStartTime, String currentWeekEndTime){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("orgId", orgId);
        params.put("userId", user.getId());
        params.put("companyId", user.getCompanyId());
        params.put("currentWeekStart", currentWeekStartTime);
        params.put("currentWeekEnd", currentWeekEndTime);

        sqlCache.executeSql(CapacityQuery.duplicateCapacityWeek, params);
        //return getCapcitySchedule for the new week (this will include the existing bookings)
        return getCapacitySchedule(orgId, currentWeekStartTime, currentWeekEndTime);
    }

}
