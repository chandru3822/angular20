package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CallGroup;
import com.albatross.api.v1.company.blueraven.models.CallGroupPhoneNumber;
import com.albatross.api.v1.company.blueraven.models.CallGroupPostalCode;
import com.albatross.api.v1.company.blueraven.services.CallGroupService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping(
    value = "/api/v1/company/blueraven/callGroup",
    produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class CallGroupController {

  private final CallGroupService callGroupService;

  @GetMapping(value = "")
  public List<CallGroup> getCallGroups(@RequestParam(required = false) String searchQuery) {
    return callGroupService.getGroups(searchQuery);
  }

  @GetMapping(value = "/{id}")
  public CallGroup getGroupDetails(@PathVariable Long id) {
    return callGroupService.getGroupDetails(id);
  }

  @GetMapping(value = "/{id}/codes")
  public List<CallGroupPostalCode> getCodesForGroup(@PathVariable Long id) {
    return callGroupService.getCodesForGroup(id);
  }

  @GetMapping(value = "/{id}/numbers")
  public List<CallGroupPhoneNumber> getNumbersForGroup(@PathVariable Long id) {
    return callGroupService.getNumbersForGroup(id);
  }

  @PostMapping(value = "")
  public CallGroup saveGroup(@RequestBody CallGroup callGroup) {
    return callGroupService.saveGroup(callGroup);
  }

  @PostMapping(value = "/config")
  public void saveGroupConfig(@RequestBody CallGroup callGroup) {
    callGroupService.saveGroupConfig(callGroup);
  }

  @DeleteMapping(value = "/{id}")
  public void deleteGroup(@PathVariable Long id) {
    callGroupService.deleteGroup(id);
  }

  @PostMapping(value = "/addCode")
  public ResponseEntity addPostalCode(@RequestBody CallGroupPostalCode postalCode) {
    return callGroupService.addPostalCode(postalCode);
  }

  @PostMapping(value = "/addNumber")
  public ResponseEntity addPhoneNumber(@RequestBody CallGroupPhoneNumber phoneNumber) {
    return callGroupService.addPhoneNumber(phoneNumber);
  }

  @PostMapping(value = "/updateNumber")
  public void updatePhoneNumber(@RequestBody CallGroupPhoneNumber cgpn) {
    callGroupService.updatePhoneNumber(cgpn);
  }

  @DeleteMapping(value = "/code/{id}")
  public void deletePostalCode(@PathVariable Long id) {
    callGroupService.deletePostalCode(id);
  }

  @DeleteMapping(value = "/number/{id}")
  public void deletePhoneNumber(@PathVariable Long id) {
    callGroupService.deletePhoneNumber(id);
  }
}
