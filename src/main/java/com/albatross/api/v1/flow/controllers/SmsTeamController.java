package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamOrg;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamPosition;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamUser;
import com.albatross.api.v1.flow.services.SmsTeamService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by John on 2022-01-21.
 */
@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/smsTeam")
public class SmsTeamController {

  private final SmsTeamService smsTeamService;

  @PutMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
  public SmsTeam saveTeam(@RequestBody SmsTeam st) {
    return smsTeamService.saveTeam(st);
  }

  @GetMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<SmsTeam> getTeams() {
    return smsTeamService.getTeams();
  }

  @GetMapping(value = "/users", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<SmsTeam> getTeamsUsers() {
    return smsTeamService.getTeamsUsers();
  }

  @PutMapping(value = "/{smsTeamId}/delete", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTeam(@PathVariable Long smsTeamId) {
    smsTeamService.deleteTeam(smsTeamId);
  }

  @PostMapping(value = "/{smsTeamId}/position/{positionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<SmsTeamPosition> addPosition(@PathVariable Long smsTeamId,
                                                     @PathVariable Long positionId) {
    return smsTeamService.addPosition(smsTeamId, positionId);
  }

  @DeleteMapping(value = "/{smsTeamId}/position/{positionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePosition(@PathVariable Long smsTeamId, @PathVariable Long positionId) throws Exception {
    smsTeamService.deletePosition(smsTeamId, positionId);
  }

  @PostMapping(value = "/{smsTeamId}/user/{userId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<SmsTeamUser> addUser(@PathVariable Long smsTeamId,
                                             @PathVariable Long userId) {
    return smsTeamService.addUser(smsTeamId, userId);
  }

  @DeleteMapping(value = "/{smsTeamId}/user/{teamUserId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteUser(@PathVariable Long smsTeamId, @PathVariable Long teamUserId) throws Exception {
    smsTeamService.deleteUser(smsTeamId, teamUserId);
  }

  @PostMapping(value = "/{smsTeamId}/org/{orgId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<SmsTeamOrg> addOrg(@PathVariable Long smsTeamId,
                                           @PathVariable Long orgId) {
    return smsTeamService.addOrg(smsTeamId, orgId);
  }

  @DeleteMapping(value = "/{smsTeamId}/org/{orgId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteOrg(@PathVariable Long smsTeamId, @PathVariable Long orgId) {
    smsTeamService.deleteOrg(smsTeamId, orgId);
  }

  @GetMapping(value = "/getTeamsForUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<SmsTeam> getTeamsForUser() {
    return smsTeamService.getTeamsForUser();
  }

}
