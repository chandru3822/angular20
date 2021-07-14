package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.SmartlistResult;
import com.albatross.api.v1.flow.model.WorkQueue;
import com.albatross.api.v1.flow.model.WorkQueueOwner;
import com.albatross.api.v1.flow.services.WorkQueueService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/workQueue")
public class WorkQueueController {

  @Autowired
  private WorkQueueService workQueueService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueue> getWorkQueues (@RequestParam(required = false) Long workQueueCategoryId,
                                        @RequestParam(required = false) Boolean unassigned,
                                        @RequestParam(required = false) Long userId) {
    return workQueueService.getWorkQueues(workQueueCategoryId, userId, unassigned);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public SmartlistResult getWorkQueueDetails (@PathVariable Long id,
                                              @RequestParam Long smartlistId,
                                              @RequestParam(required = false) Boolean unassigned,
                                              @RequestParam(required = false) Long userId,
                                              Pageable pageable) {
    return workQueueService.getWorkQueueDetails(id, smartlistId, userId, unassigned, pageable);
  }

  @GetMapping(value = "/owners", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueOwner> getWorkQueueOwners () {
    return workQueueService.getWorkQueueOwners();
  }

  @GetMapping(value = "/smartlist/{id}/buildSql", produces = MediaType.APPLICATION_JSON_VALUE)
  public String buildSql (@PathVariable Long id) {
    return workQueueService.buildSql(id);
  }

}
