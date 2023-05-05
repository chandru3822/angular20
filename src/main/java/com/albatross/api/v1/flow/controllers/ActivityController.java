package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.Activity;
import com.albatross.api.v1.flow.services.ActivityService;
import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/activity")
public class ActivityController {

  private final ActivityService activityService;

  @GetMapping(value = "/project/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Activity> getProjectActivities(@PathVariable Long id) {
    return activityService.getActivitiesByObject(ObjectType.PROJECT.id, id);
  }

  @PostMapping(value = "/project/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> addProjectActivity(@PathVariable Long id, @RequestBody Activity activity) {
    return activityService.addActivityByObject(ObjectType.PROJECT.id, id, activity);
  }

}
