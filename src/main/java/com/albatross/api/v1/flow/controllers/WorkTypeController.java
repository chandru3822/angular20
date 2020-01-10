package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.WorkType;
import com.albatross.api.v1.flow.services.WorkTypeService;
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
@RequestMapping(value = "/api/v1/flow/workType")
public class WorkTypeController {

  @Autowired
  private WorkTypeService workTypeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkType> getWorkTypes () {
    return workTypeService.getWorkTypes();
  }

  @DeleteMapping(value = "/type/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    workTypeService.deleteType(typeId);
  }

  @PutMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateType(@RequestBody WorkType type) {
    workTypeService.updateType(type);
  }

  @PostMapping(value = "/type", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkType> insertType(@RequestBody WorkType type) {
    return workTypeService.insertType(type);
  }

}
