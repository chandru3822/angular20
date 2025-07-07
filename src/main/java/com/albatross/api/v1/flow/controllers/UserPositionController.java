package com.albatross.api.v1.flow.controllers;


import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.ActiveUserPosition;
import com.albatross.api.v1.flow.model.UserPosition;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.services.UserPositionService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

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
  
	/**
	 * @param positionId
	 * @param searchQuery
	 * @param pageable
	 * @return
	 */
	@GetMapping(value = "/search", produces = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<Page<ActiveUserPosition>> searchActiveUser(@RequestParam Integer positionId,
			@RequestParam String searchQuery, Pageable pageable) {
		return new ResponseEntity<>(userPositionService.searchActiveUser(positionId, searchQuery, pageable),
				HttpStatus.OK);
	}
  
}
