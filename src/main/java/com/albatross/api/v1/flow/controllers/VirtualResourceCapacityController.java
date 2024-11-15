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

    @GetMapping(value="/capacityScheduleForRange")
    public List<VirtualResourceCapacitySchedule> getCapacityScheduleForRange(
            @RequestParam Long orgId,
            @RequestParam String startTime,
            @RequestParam String endTime){
        return virtualResourceCapacityService.getCapacitySchedule(orgId, startTime, endTime);
    }

    //todo: getBookedForRange function

    @PostMapping(value="/maxCapacityList")
    public void updateMaxCapacity(
            @RequestParam List<VirtualResourceCapacitySchedule> resourceCapacitySchedules){
        virtualResourceCapacityService.updateMaxCapacity(resourceCapacitySchedules);
    }

    @PostMapping("/duplicateWeek")
    public List<VirtualResourceCapacitySchedule> duplicatePreviousWeek(
            @RequestParam Long orgId,
            @RequestParam String currentWeekStartTime,
            @RequestParam String currentWeekEndTime){
        return virtualResourceCapacityService.duplicatePreviousWeek(orgId, currentWeekStartTime, currentWeekEndTime);
    }

}
