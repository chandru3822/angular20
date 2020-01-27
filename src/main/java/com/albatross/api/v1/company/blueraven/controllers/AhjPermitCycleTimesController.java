//package com.albatross.api.v1.company.blueraven.controllers;
//
//import com.albatross.api.v1.company.blueraven.models.ahj.cycle_times.AhjPermitCycleTimeStats;
//import com.albatross.api.v1.company.blueraven.services.AhjPermitService;
//import com.albatross.api.utils.ServiceDateUtils;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.web.bind.annotation.PathVariable;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RestController;
//
//import java.time.LocalDate;
//import java.util.Optional;

import static org.springframework.web.bind.annotation.RequestMethod.GET;

// TODO: come back to this after the migration of custom fields has taken place
//@Slf4j
//@RestController
//@RequestMapping(value = "/api/v1/ahj/{ahjId}/permitcycletimes")
//@RequiredArgsConstructor
//public class AhjPermitCycleTimesController {
//    private final AhjPermitService ahjPermitService;
//
//    @RequestMapping(method = GET, value = "",
//            params = {"start", "end"})
//    public Optional<AhjPermitCycleTimeStats> getCycleTimeSummary(@PathVariable Long ahjId,
//                                                                 String start, String end) {
//        LocalDate startDate = ServiceDateUtils.parseDate(start),
//                  endDate   = ServiceDateUtils.parseDate(end);
//
//        return ahjPermitService.getPermitCycleTimeStats(ahjId, startDate, endDate);
//    }
//
//    @RequestMapping(method = GET,
//            value = "/details/permits/{status}",
//            params = { "start", "end" })
//    public String getPermitCycleTimeDetails(@PathVariable Long ahjId,
//                                            @PathVariable String status,
//                                            String start,
//                                            String end) {
//        LocalDate startDate = ServiceDateUtils.parseDate(start),
//                  endDate   = ServiceDateUtils.parseDate(end);
//
//        return ahjPermitService.getPermitCycleTimeDetails(ahjId, startDate, endDate, status);
//    }
//
//    @RequestMapping(method = GET,
//            value = "/details/as-builts/{status}",
//            params = { "start", "end" })
//    public String getAsBuiltsCycleTimeDetails(@PathVariable Long ahjId,
//                                              @PathVariable String status,
//                                              String start,
//                                              String end) {
//        LocalDate startDate = ServiceDateUtils.parseDate(start),
//                  endDate   = ServiceDateUtils.parseDate(end);
//
//        return ahjPermitService.getAsBuiltsCycleTimeDetails(ahjId, startDate, endDate, status);
//    }
//}
