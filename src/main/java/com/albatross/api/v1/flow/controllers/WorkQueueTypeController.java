package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.WorkQueueType;
import com.albatross.api.v1.flow.services.WorkQueueTypeService;
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
@RequestMapping(value = "/api/v1/flow/workQueueType")
public class WorkQueueTypeController {

  @Autowired
  private WorkQueueTypeService workQueueTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueType> getWorkQueueTypes () {
    return workQueueTypeService.getWorkQueueTypes();
  }

  @DeleteMapping(value = "/type/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    workQueueTypeService.deleteType(typeId);
  }

  @PutMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateType(@RequestBody WorkQueueType type) {
    workQueueTypeService.updateType(type);
  }

  @PostMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueType> insertType(@RequestBody WorkQueueType type) {
    return workQueueTypeService.insertType(type);
  }

}
