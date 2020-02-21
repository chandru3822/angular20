package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.WorkQueue;
import com.albatross.api.v1.flow.model.WorkQueueDetail;
import com.albatross.api.v1.flow.model.WorkQueueOwner;
import com.albatross.api.v1.flow.services.WorkQueueService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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
                                        @RequestParam(required = false) Long userPositionId) {
    return workQueueService.getWorkQueues(workQueueCategoryId, userPositionId, unassigned);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueDetail> getWorkQueueDetails (@PathVariable Long id,
                                                    @RequestParam(required = false) Boolean unassigned,
                                                    @RequestParam(required = false) Long userPositionId) {
    return workQueueService.getWorkQueueDetails(id, userPositionId, unassigned);
  }

  @GetMapping(value = "/owners", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueOwner> getWorkQueueOwners () {
    return workQueueService.getWorkQueueOwners();
  }

}
