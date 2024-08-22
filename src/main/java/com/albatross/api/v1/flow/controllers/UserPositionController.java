package com.albatross.api.v1.flow.controllers;


import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.UserPosition;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.services.UserPositionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/userPosition")
public class UserPositionController {

  private final UserPositionService userPositionService;
  private final SecurityService securityService;

  @GetMapping(value = "/{userId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<UserPosition> getUserPositions(@PathVariable Long userId) {
    return userPositionService.getUserPositions(userId);
  }

  @GetMapping(value = "/{userId}/primary", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<UserPosition> getUserPrimaryPosition(@PathVariable Long userId) {
    var companyId = securityService.getCurrentUser().getCompanyId();
    var position = userPositionService.getUserPrimaryPosition(userId, companyId);
    if (position == null) {
      position = new UserPosition();
    }
    return new ResponseEntity<>(position, HttpStatus.OK);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public UserPosition saveUserPosition(@RequestBody UserPosition userPosition) {
    return userPositionService.saveUserPosition(userPosition);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteUserPosition(@PathVariable Long id) {
    userPositionService.deleteUserPosition(id);
  }

  @GetMapping(value = "/availableSalesOrgs", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Org> deleteUserPosition(@RequestParam Long positionId,
                                      @RequestParam Long orgId) {
    return userPositionService.getAvailableSalesOrgs(positionId, orgId);
  }

}
