package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.ahj.cycle_times.AhjPermitCycleTimeStats;
import com.albatross.api.v1.company.blueraven.services.AhjPermitService;
import com.albatross.api.utils.ServiceDateUtils;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Optional;

@Slf4j
@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/ahj/{ahjId}/permitCycleTimes")
public class AhjPermitCycleTimesController {
    @Autowired
    private AhjPermitService ahjPermitService;

    @GetMapping(value = "")
    public Optional<AhjPermitCycleTimeStats> getCycleTimeSummary(@PathVariable Long ahjId,
                                                                 @RequestParam String start,
                                                                 @RequestParam String end) {
        LocalDate startDate = ServiceDateUtils.parseDate(start);
        LocalDate endDate = ServiceDateUtils.parseDate(end);

//        return ahjPermitService.getPermitCycleTimeStats(ahjId, startDate, endDate);
        return null; // TODO: remove once needed columns are added to database
    }

    @GetMapping(value = "/details/permits/{status}")
    public String getPermitCycleTimeDetails(@PathVariable Long ahjId,
                                            @PathVariable String status,
                                            @RequestParam String start,
                                            @RequestParam String end) {
        LocalDate startDate = ServiceDateUtils.parseDate(start);
        LocalDate endDate = ServiceDateUtils.parseDate(end);

//        return ahjPermitService.getPermitCycleTimeDetails(ahjId, startDate, endDate, status);
        return null; // TODO: remove once needed columns are added to database
    }

    @GetMapping(value = "/details/as-builts/{status}")
    public String getAsBuiltsCycleTimeDetails(@PathVariable Long ahjId,
                                              @PathVariable String status,
                                              @RequestParam String start,
                                              @RequestParam String end) {
        LocalDate startDate = ServiceDateUtils.parseDate(start);
        LocalDate endDate = ServiceDateUtils.parseDate(end);

//        return ahjPermitService.getAsBuiltsCycleTimeDetails(ahjId, startDate, endDate, status);
        return null; // TODO: remove once needed columns are added to database
    }
}
