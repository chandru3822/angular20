package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.VirtualResourceCapacitySchedule;
import com.albatross.api.v1.flow.services.VirtualResourceCapacityService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value ="/api/v1/flow/virtualResourceCapacity", produces = MediaType.APPLICATION_JSON_VALUE)
public class VirtualResourceCapacityController {

    private final VirtualResourceCapacityService virtualResourceCapacityService;

    /**
     * Gets a list of all the half hour timeslots within a given range (typically a week) and the max capacity and count of booked events for each timeslot
     * @param orgId
     * @param startTime - format: "EEE MMM dd yyyy HH:mm:ss 'GMT'Z" (should already be converted to UTC)
     * @param endTime - format: "EEE MMM dd yyyy HH:mm:ss 'GMT'Z" (should already be converted to UTC)
     * @return
     */
    @GetMapping(value="/capacityScheduleForRange")
    public List<VirtualResourceCapacitySchedule> getCapacityScheduleForRange(
            @RequestParam Long orgId,
            @RequestParam String startTime,
            @RequestParam String endTime){
        return virtualResourceCapacityService.getCapacitySchedule(orgId, startTime, endTime);
    }

    /**
     * Gets a list of all the half hour timeslots within a given range (typically a week) and the count of booked events for each timeslot
     * @param orgId
     * @param startTime - format: "EEE MMM dd yyyy HH:mm:ss 'GMT'Z" (should already be converted to UTC)
     * @param endTime - format "EEE MMM dd yyyy HH:mm:ss 'GMT'Z" (should already be converted to UTC)
     * @return
     */
    @GetMapping(value = "/bookedForRange")
    public List<VirtualResourceCapacitySchedule> getBookedForRange(
            @RequestParam Long orgId,
            @RequestParam String startTime,
            @RequestParam String endTime){
        return virtualResourceCapacityService.getBookedForRange(orgId, startTime, endTime);
    }

    @PutMapping(value="/maxCapacityList")
    public void updateMaxCapacity(
            @RequestParam Long orgId,
            @RequestBody List<VirtualResourceCapacitySchedule> resourceCapacitySchedules
            ){
        virtualResourceCapacityService.updateMaxCapacity(resourceCapacitySchedules, orgId);
    }

    @PostMapping("/duplicateWeek")
    public List<VirtualResourceCapacitySchedule> duplicatePreviousWeek(
            @RequestParam Long orgId,
            @RequestParam String currentWeekStartTime,
            @RequestParam String currentWeekEndTime){
        return virtualResourceCapacityService.duplicatePreviousWeek(orgId, currentWeekStartTime, currentWeekEndTime);
    }

}
