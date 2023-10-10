package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.enums.RoundRobinUserType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.PostalCode;
import com.albatross.api.v1.flow.model.roundRobin.RoundRobinAllocationUser;
import com.albatross.api.v1.flow.model.roundRobin.RoundRobin;
import com.albatross.api.v1.flow.model.roundRobin.RoundRobinUser;
import com.albatross.api.v1.flow.services.RoundRobinService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/roundRobin")
public class RoundRobinController {

  private final RoundRobinService roundRobinService;


  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobin> getRoundRobins(@RequestParam(required=false) String searchQuery) {
    return roundRobinService.getRoundRobins(searchQuery);
  }

  @GetMapping(value = "/forUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobin> getRoundRobinsForUser() {
    return roundRobinService.getRoundRobinsForUser();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public RoundRobin getRoundRobinDetails(@PathVariable Long id) {
    return roundRobinService.getRoundRobin(id);
  }

  @GetMapping(value = "/{id}/scheduleTo", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobinAllocationUser> getScheduleToUsers(@PathVariable Long id) {
    return roundRobinService.getScheduleToUsers(id);
  }

  @GetMapping(value = "/{id}/scheduleBy", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobinUser> getScheduleByUsers(@PathVariable Long id) {
    return roundRobinService.getScheduleByUsers(id);
  }

  @GetMapping(value = "/{id}/codes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCode> getAssignedCodesForRoundRobin(@PathVariable Long id) {
    return roundRobinService.getAssignedCodesForRoundRobin(id);
  }

  @GetMapping(value = "/{id}/availableCodes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCode> getAvailableCodesForRoundRobin(@PathVariable Long id) {
    return roundRobinService.getAvailableCodesForRoundRobin(id);
  }

  @PutMapping(value = "/{id}/userAllocation", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobinAllocationUser> saveManualUserAllocation(@PathVariable Long id,
                                                                 @RequestBody List<RoundRobinAllocationUser> allocationUsers) {
    return roundRobinService.saveManualUserAllocations(id, allocationUsers);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public RoundRobin saveRoundRobin(@RequestBody RoundRobin roundRobin) {
    return roundRobinService.saveRoundRobin(roundRobin);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteRoundRobin(@PathVariable Long id) {
    roundRobinService.deleteRoundRobin(id);
  }

  @PostMapping(value = "/{id}/saveScheduleToUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobinAllocationUser> insertScheduleToUser(@PathVariable Long id,
                                                             @RequestBody RoundRobinUser user) {
    return roundRobinService.insertAllocationUser(id, user);
  }

  @PutMapping(value = "/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public RoundRobinUser updateAllocationUser(@PathVariable Long id,
                                             @RequestBody RoundRobinAllocationUser user) {
    return roundRobinService.updateAllocationUser(id, user);
  }

  @PostMapping(value = "/saveScheduleByUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public RoundRobinUser insertScheduleByUser(@RequestBody RoundRobinUser user) {
    return roundRobinService.insertUser(user, RoundRobinUserType.SCHEDULE_BY.id);
  }

  @DeleteMapping(value = "/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteUser(@PathVariable Long id) {
    roundRobinService.deleteUser(id);
  }

  @PutMapping(value = "/{id}/user/{userId}/delete", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobinAllocationUser> deleteAllocationUser(@PathVariable Long id,
                                                             @PathVariable Long userId) {
    return roundRobinService.deleteAllocationUser(id, userId);
  }

  @PostMapping(value = "/{id}/addCode", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity addCode(@PathVariable Long id,
                                @RequestBody PostalCode postalCode) {
    return roundRobinService.addCode(id, postalCode);
  }

  @DeleteMapping(value = "/code/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCode(@PathVariable Long id) {
    roundRobinService.deleteRoundRobinFromPostalCode(id);
  }

  @GetMapping(value = "/{id}/users", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getAvailableRoundRobinUsers(@PathVariable Long id) {
    return roundRobinService.getAvailableRoundRobinUsers(id, false);
  }

  @GetMapping(value = "/byPostalCode", produces = MediaType.APPLICATION_JSON_VALUE)
  public RoundRobin getRoundRobinByPostalCode(@RequestParam String postalCode,
                                        @RequestParam Long projectId) {
    return roundRobinService.getRoundRobinByPostalCode(postalCode, projectId);
  }

  @GetMapping(value = "/{id}/schedulers", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getAvailableRoundRobinSchedulers(@PathVariable Long id) {
    return roundRobinService.getAvailableRoundRobinUsers(id, true);
  }

  @GetMapping(value = "/userCanSchedule", produces = MediaType.APPLICATION_JSON_VALUE)
  public Boolean userCanSchedule(@RequestParam String postalCode) {
    return roundRobinService.userCanSchedule(postalCode);
  }

  @GetMapping(value = "/userCanScheduleRemote", produces = MediaType.APPLICATION_JSON_VALUE)
  public Boolean userCanScheduleRemote() {
    return roundRobinService.userCanScheduleRemote();
  }

  @Data
  public static class RoundRobinUserRequest {
    private List<Integer> roundRobinIds;
  }

  //this is currently only used by the BRS - Closer Availability feature, if it needs to be used elsewhere it will probably need to change
  @PostMapping(value = "/users", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobinUser> getAllRoundRobinUsers(@RequestBody RoundRobinUserRequest request) throws SQLException {
    return roundRobinService.getAllRoundRobinUsers(request.getRoundRobinIds());
  }

  @PostMapping(value = "/usersByDownline", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RoundRobinUser> getRoundRobinUsersByDownline(@RequestBody RoundRobinUserRequest request) throws SQLException {
    return roundRobinService.getRoundRobinUsersByDownline(request.getRoundRobinIds());
  }
}
