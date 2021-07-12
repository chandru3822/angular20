package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.CallGroup;
import com.albatross.api.v1.company.blueraven.models.CallGroupPhoneNumber;
import com.albatross.api.v1.company.blueraven.models.CallGroupPostalCode;
import com.albatross.api.v1.company.blueraven.services.CallGroupService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/callGroup")
public class CallGroupController {

  private final CallGroupService callGroupService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CallGroup> getCallGroups(@RequestParam(required=false) String searchQuery) {
    return callGroupService.getGroups(searchQuery);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public CallGroup getGroupDetails(@PathVariable Long id) {
    return callGroupService.getGroupDetails(id);
  }

  @GetMapping(value = "/{id}/codes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CallGroupPostalCode> getCodesForGroup(@PathVariable Long id) {
    return callGroupService.getCodesForGroup(id);
  }

  @GetMapping(value = "/{id}/numbers", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CallGroupPhoneNumber> getNumbersForGroup(@PathVariable Long id) {
    return callGroupService.getNumbersForGroup(id);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public CallGroup saveGroup(@RequestBody CallGroup callGroup) {
    return callGroupService.saveGroup(callGroup);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteGroup(@PathVariable Long id) {
    callGroupService.deleteGroup(id);
  }

  @PostMapping(value = "/addCode", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity addPostalCode(@RequestBody CallGroupPostalCode postalCode) {
    return callGroupService.addPostalCode(postalCode);
  }

  @PostMapping(value = "/addNumber", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity addPhoneNumber(@RequestBody CallGroupPhoneNumber phoneNumber) {
    return callGroupService.addPhoneNumber(phoneNumber);
  }

  @PostMapping(value = "/updateNumber", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updatePhoneNumber(@RequestBody CallGroupPhoneNumber cgpn) {
    callGroupService.updatePhoneNumber(cgpn);
  }

  @DeleteMapping(value = "/code/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePostalCode(@PathVariable Long id) {
    callGroupService.deletePostalCode(id);
  }

  @DeleteMapping(value = "/number/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePhoneNumber(@PathVariable Long id) {
    callGroupService.deletePhoneNumber(id);
  }
}
