package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.ScheduleController;
import com.albatross.api.v1.flow.model.ScheduleEvent;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.VirtualResourceCapacitySchedule;
import com.albatross.api.v1.flow.queries.CapacityQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


@Slf4j
@Service
@RequiredArgsConstructor
public class VirtualResourceCapacityService {

    private final SqlCache sqlCache;
    private final SecurityService securityService;
    private final ScheduleService scheduleService;
    private final UserPositionService userPositionService;


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
        ScheduleController.EventSearchParams esp = new ScheduleController.EventSearchParams();
        esp.setOrgIds(List.of(orgId));
        List<Long> userPositionIds = userPositionService.getUserPositionIdsForOrgPosition(761L, orgId); //todo: get prod position Id or pass it in with params
        esp.setUserPositionIds(userPositionIds);
        esp.setStartTime(startTime);
        esp.setEndTime(endTime);
        esp.setIncludeCancelledEvents(false);
        esp.setIncludeCancelledProjects(false);

        List<ScheduleEvent> events = scheduleService.getEventsForCompanyByOrgAndUser(esp);

        // Define a formatter for the input string format
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        // Parse the input strings into LocalDateTime
        LocalDateTime start = LocalDateTime.parse(startTime, formatter);
        LocalDateTime end = LocalDateTime.parse(endTime, formatter);



        List<VirtualResourceCapacitySchedule> bookedForRange = new ArrayList<VirtualResourceCapacitySchedule>();

        DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        // Loop through every half-hour interval, get the count, and add it to the bookedForRange list
        while (start.isBefore(end)) {

            //get booked counts for half-hour intervals between 6am and 10pm
                VirtualResourceCapacitySchedule bookedFor30MinInterval = new VirtualResourceCapacitySchedule();
                bookedFor30MinInterval.setStart(outputFormatter.format(start.atZone(ZoneId.of("GMT"))));
                LocalDateTime intervalEnd = start.plusMinutes(30);
                bookedFor30MinInterval.setEnd(outputFormatter.format(intervalEnd.atZone(ZoneId.of("GMT"))));
                Long intervalCount = countEventsInInterval(events, start, intervalEnd);
                bookedFor30MinInterval.setCurrentlyBooked(intervalCount);
                bookedForRange.add(bookedFor30MinInterval);
                start = intervalEnd;
        }
         return bookedForRange;
    }

    public Long countEventsInInterval(List<ScheduleEvent> events, LocalDateTime start, LocalDateTime end){
        List<ScheduleEvent> eventsInInterval = events.stream().filter(event -> {
            LocalDateTime eventStart = event.getStart().toInstant().atZone(ZoneOffset.UTC).toLocalDateTime();
            LocalDateTime eventEnd = event.getEnd().toInstant().atZone(ZoneOffset.UTC).toLocalDateTime();
            return (eventStart.isAfter(start) && eventStart.isBefore(end)) ||
                    (eventEnd.isAfter(start) && eventEnd.isBefore(end)) ||
                    (start.isAfter(eventStart) && start.isBefore(eventEnd));
        }).toList();
        return (long) eventsInInterval.size();
    }

    public Long getCurrentBookedCountForCapacityScheduleRow(Long orgId, String startTime, String endTime){
        HashMap<String, Object> params = new HashMap<>();
        params.put("orgId", orgId);
        params.put("positionId", 761L);//todo: get prod position Id or pass it in with params
        params.put("startTime", startTime);
        params.put("endTime", endTime);

        User currentUser = securityService.getCurrentUser();
        params.put("companyId", currentUser.getCompanyId());

        return sqlCache.queryForObjectBySql(CapacityQuery.getOrgEventCount, params, Long.class);
    }

    public List<VirtualResourceCapacitySchedule> getCapacitySchedule(Long orgId, String rangeStartTime, String rangeEndTime){
        //getCapacityForRange only gets the timeslots that HAVE a capacity value
        List<VirtualResourceCapacitySchedule> capacitySchedules = getCapacityForRange(orgId, rangeStartTime, rangeEndTime);
        //getBookedForRange gets every half hour timeslot between the start and end time along with the count of events booked for that timeslot
        List<VirtualResourceCapacitySchedule> booked = getBookedForRange(orgId, rangeStartTime, rangeEndTime);
        if(capacitySchedules != null && booked != null) {
            //go through all the timeslots and look for a matching timeslot in capacitySchedules
            for (VirtualResourceCapacitySchedule timeSlotSchedule : booked) {
                Optional<VirtualResourceCapacitySchedule> schedule = capacitySchedules.stream().filter(cs -> cs.getStart().equals(timeSlotSchedule.getStart()) && cs.getEnd().equals(timeSlotSchedule.getEnd())).findFirst();
                //if a value is found add the capacity value to the VirtualResourceCapacitySchedule for that timeslot schedule in the booked list so it now has booked and max capacity
                schedule.ifPresent(virtualResourceCapacitySchedule -> timeSlotSchedule.setMaxCapacity(virtualResourceCapacitySchedule.getMaxCapacity()));
            }
            return booked; //return the booked list which should now have all the combined data
        }
        return null;
    }

    public void updateMaxCapacity(List<VirtualResourceCapacitySchedule> resourceCapacitySchedules, Long orgId){
        User user = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", user.getId());
        params.put("companyId", user.getCompanyId());
        params.put("orgId", orgId);


        for (VirtualResourceCapacitySchedule capacity: resourceCapacitySchedules) {
            params.put("maxCapacity", capacity.getMaxCapacity());

            params.put("startTime", stringToTimestamp(capacity.getStart()));
            params.put("endTime", stringToTimestamp(capacity.getEnd()));
            sqlCache.updateBySql(CapacityQuery.upsertMaxCapacity, params);
        }
    }

    public Timestamp stringToTimestamp(String dateTimeString) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEE MMM dd yyyy HH:mm:ss 'GMT'Z");
        LocalDateTime localDateTime = LocalDateTime.parse(dateTimeString, formatter);
        return Timestamp.valueOf(localDateTime);
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
