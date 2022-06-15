package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamOrg;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamPosition;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamUser;
import com.albatross.api.v1.flow.services.SmsTeamService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/** Created by John on 2022-01-21. */
@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/smsTeam", produces = MediaType.APPLICATION_JSON_VALUE)
public class SmsTeamController {
  private final SmsTeamService smsTeamService;

  @PutMapping(value = "/")
  public SmsTeam saveTeam(@RequestBody SmsTeam st) {
    return smsTeamService.saveTeam(st);
  }

  @GetMapping(value = "/")
  public List<SmsTeam> getTeams() {
    return smsTeamService.getTeams();
  }

  @GetMapping(value = "/users")
  public List<SmsTeam> getTeamsUsers() {
    return smsTeamService.getTeamsUsers();
  }

  @PutMapping(value = "/{smsTeamId}/delete")
  public void deleteTeam(@PathVariable Long smsTeamId) {
    smsTeamService.deleteTeam(smsTeamId);
  }

  @PostMapping(value = "/{smsTeamId}/position/{positionId}")
  public Optional<SmsTeamPosition> addPosition(
      @PathVariable Long smsTeamId, @PathVariable Long positionId) {
    return smsTeamService.addPosition(smsTeamId, positionId);
  }

  @DeleteMapping(value = "/{smsTeamId}/position/{positionId}")
  public void deletePosition(@PathVariable Long smsTeamId, @PathVariable Long positionId)
      throws Exception {
    smsTeamService.deletePosition(smsTeamId, positionId);
  }

  @PostMapping(value = "/{smsTeamId}/user/{userId}")
  public Optional<SmsTeamUser> addUser(@PathVariable Long smsTeamId, @PathVariable Long userId) {
    return smsTeamService.addUser(smsTeamId, userId);
  }

  @DeleteMapping(value = "/{smsTeamId}/user/{teamUserId}")
  public void deleteUser(@PathVariable Long smsTeamId, @PathVariable Long teamUserId)
      throws Exception {
    smsTeamService.deleteUser(smsTeamId, teamUserId);
  }

  @PostMapping(value = "/{smsTeamId}/org/{orgId}")
  public Optional<SmsTeamOrg> addOrg(@PathVariable Long smsTeamId, @PathVariable Long orgId) {
    return smsTeamService.addOrg(smsTeamId, orgId);
  }

  @DeleteMapping(value = "/{smsTeamId}/org/{orgId}")
  public void deleteOrg(@PathVariable Long smsTeamId, @PathVariable Long orgId) {
    smsTeamService.deleteOrg(smsTeamId, orgId);
  }

  @GetMapping(value = "/getTeamsForUser")
  public List<SmsTeam> getTeamsForUser() {
    return smsTeamService.getTeamsForUser();
  }
}
