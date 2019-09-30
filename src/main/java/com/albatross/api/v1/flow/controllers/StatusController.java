package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.StatusType;
import com.albatross.api.v1.flow.services.StatusService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/status")
public class StatusController {

  @Autowired
  private StatusService statusService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<StatusType> getStatusTypesForCompany () {
    return statusService.getStatusTypesForCompany();
  }

  @DeleteMapping(value = "/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    statusService.deleteType(typeId);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateProcess(@RequestBody StatusType type) {
    statusService.updateType(type);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<StatusType> insertProcess(@RequestBody StatusType type) {
    return statusService.insertType(type);
  }

}
