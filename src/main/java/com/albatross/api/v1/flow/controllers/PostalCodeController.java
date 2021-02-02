package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.enums.PostalCodeZoneUserType;
import com.albatross.api.v1.flow.model.PostalCode;
import com.albatross.api.v1.flow.model.PostalCodeZone;
import com.albatross.api.v1.flow.model.PostalCodeZoneUser;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.PostalCodeService;
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
@RequestMapping(value = "/api/v1/flow/postalCode")
public class PostalCodeController {

  private final PostalCodeService postalCodeService;


  @GetMapping(value = "/zones", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCodeZone> getZones() {
    return postalCodeService.getZones();
  }

  @GetMapping(value = "/zone/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public PostalCodeZone getZoneDetails(@PathVariable Long id) {
    return postalCodeService.getZone(id);
  }

  @GetMapping(value = "/zone/{id}/scheduleTo", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCodeZoneUser> getScheduleToUsers(@PathVariable Long id) {
    return postalCodeService.getScheduleToUsers(id);
  }

  @GetMapping(value = "/zone/{id}/scheduleBy", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCodeZoneUser> getScheduleByUsers(@PathVariable Long id) {
    return postalCodeService.getScheduleByUsers(id);
  }

  @GetMapping(value = "/zone/{id}/codes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCode> getCodesForZone(@PathVariable Long id) {
    return postalCodeService.getCodesForZone(id);
  }

  @PostMapping(value = "/zone", produces = MediaType.APPLICATION_JSON_VALUE)
  public PostalCodeZone saveZone(@RequestBody PostalCodeZone zone) {
    return postalCodeService.saveZone(zone);
  }

  @DeleteMapping(value = "/zone/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteZone(@PathVariable Long id) {
    postalCodeService.deleteZone(id);
  }

  @PostMapping(value = "/zone/saveScheduleToUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public PostalCodeZoneUser insertScheduleToUser(@RequestBody PostalCodeZoneUser user) {
    return postalCodeService.insertUser(user, PostalCodeZoneUserType.SCHEDULE_TO.id);
  }

  @PostMapping(value = "/zone/saveScheduleByUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public PostalCodeZoneUser insertScheduleByUser(@RequestBody PostalCodeZoneUser user) {
    return postalCodeService.insertUser(user, PostalCodeZoneUserType.SCHEDULE_BY.id);
  }

  @DeleteMapping(value = "/zone/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteUser(@PathVariable Long id) {
    postalCodeService.deleteUser(id);
  }

  @PostMapping(value = "/zone/addCode", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity addCode(@RequestBody PostalCode postalCode) {
    return postalCodeService.addCode(postalCode);
  }

  @DeleteMapping(value = "/zone/code/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCode(@PathVariable Long id) {
    postalCodeService.deleteCode(id);
  }

  @GetMapping(value = "/zone/{id}/users", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getAvailableZoneUsers(@PathVariable Long id) {
    return postalCodeService.getAvailableZoneUsers(id, false);
  }

  @GetMapping(value = "/zone/byPostalCode", produces = MediaType.APPLICATION_JSON_VALUE)
  public PostalCodeZone getZoneByPostalCode(@RequestParam String postalCode,
                                            @RequestParam Long projectId) {
    return postalCodeService.getZoneByPostalCode(postalCode, projectId);
  }

  @GetMapping(value = "/zone/{id}/schedulers", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getAvailableZoneSchedulers(@PathVariable Long id) {
    return postalCodeService.getAvailableZoneUsers(id, true);
  }

  @GetMapping(value = "/zone/userCanSchedule", produces = MediaType.APPLICATION_JSON_VALUE)
  public Boolean userCanSchedule(@RequestParam String postalCode) {
    return postalCodeService.userCanSchedule(postalCode);
  }

  @Data
  public static class ZoneUserRequest {
    private List<Integer> zoneIds;
  }

  @PostMapping(value = "/zone/users", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getAllZoneUsers(@RequestBody ZoneUserRequest request) throws SQLException {
    return postalCodeService.getAllZoneUsers(request.getZoneIds());
  }
}
