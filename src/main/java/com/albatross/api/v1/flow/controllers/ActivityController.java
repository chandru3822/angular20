package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.Activity;
import com.albatross.api.v1.flow.model.ActivityType;
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

  @GetMapping(value = "/topics/project/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ActivityType> getProjectActivityTopics(@PathVariable Long id) {
    return activityService.getActivityTopicsByObject(ObjectType.PROJECT.id, id);
  }

  @GetMapping(value = "/project/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Activity> getProjectActivities(@PathVariable Long id) {
    return activityService.getActivitiesByObject(ObjectType.PROJECT.id, id);
  }

  @DeleteMapping(value = "/{id}/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProjectActivity(@PathVariable("id") Long activityId) {
    activityService.deleteActivityById(ObjectType.PROJECT.id, activityId);
  }
  @PostMapping(value = "/{id}/pin/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public void pinProjectActivity(@PathVariable("id") Long activityId, @RequestParam Boolean pinned) {
    activityService.pinActivity(ObjectType.PROJECT.id, activityId, pinned);
  }
  @PostMapping(value = "/project/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> addProjectActivity(@PathVariable Long id, @RequestBody Activity activity) {
    return activityService.addActivityByObject(ObjectType.PROJECT.id, id, activity);
  }

  @PutMapping(value = "/{id}/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> editProjectActivity(@PathVariable("id") Long activityId, @RequestBody Activity activity) {
    return activityService.editActivityByObject(ObjectType.PROJECT.id, activityId, activity);
  }

  // ##### CONTACT ACTIVITY STUFF #######
  @GetMapping(value = "/topics/contact/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ActivityType> getContactActivityTopics(@PathVariable Long id) {
    return activityService.getActivityTopicsByObject(ObjectType.CONTACT.id, id);
  }

  @GetMapping(value = "/contact/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Activity> getContactActivities(@PathVariable Long id) {
    return activityService.getActivitiesByObject(ObjectType.CONTACT.id, id);
  }

  @DeleteMapping(value = "/{id}/contact", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteContactActivity(@PathVariable("id") Long activityId) {
    activityService.deleteActivityById(ObjectType.CONTACT.id, activityId);
  }

  @PostMapping(value = "/contact/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> addContactActivity(@PathVariable Long id, @RequestBody Activity activity) {
    return activityService.addActivityByObject(ObjectType.CONTACT.id, id, activity);
  }

  @PutMapping(value = "/{id}/contact", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> editContactActivity(@PathVariable("id") Long activityId, @RequestBody Activity activity) {
    return activityService.editActivityByObject(ObjectType.CONTACT.id, activityId, activity);
  }

  @PostMapping(value = "/{id}/pin/contact", produces = MediaType.APPLICATION_JSON_VALUE)
  public void pinContactActivity(@PathVariable("id") Long activityId, @RequestParam Boolean pinned) {
    activityService.pinActivity(ObjectType.CONTACT.id, activityId, pinned);
  }

  // ##### ORG ACTIVITY STUFF #######
  @GetMapping(value = "/topics/org/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ActivityType> getOrgActivityTopics(@PathVariable Long id) {
    return activityService.getActivityTopicsByObject(ObjectType.ORGANIZATION.id, id);
  }

  @GetMapping(value = "/org/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Activity> getOrgActivities(@PathVariable Long id) {
    return activityService.getActivitiesByObject(ObjectType.ORGANIZATION.id, id);
  }

  @DeleteMapping(value = "/{id}/org", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteOrgActivity(@PathVariable("id") Long activityId) {
    activityService.deleteActivityById(ObjectType.ORGANIZATION.id, activityId);
  }

  @PostMapping(value = "/org/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> addOrgActivity(@PathVariable Long id, @RequestBody Activity activity) {
    return activityService.addActivityByObject(ObjectType.ORGANIZATION.id, id, activity);
  }

  @PutMapping(value = "/{id}/org", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> editOrgActivity(@PathVariable("id") Long activityId, @RequestBody Activity activity) {
    return activityService.editActivityByObject(ObjectType.ORGANIZATION.id, activityId, activity);
  }

  @PostMapping(value = "/{id}/pin/org", produces = MediaType.APPLICATION_JSON_VALUE)
  public void pinOrgActivity(@PathVariable("id") Long activityId, @RequestParam Boolean pinned) {
    activityService.pinActivity(ObjectType.ORGANIZATION.id, activityId, pinned);
  }

  // ##### USER ACTIVITY STUFF #######
  @GetMapping(value = "/topics/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ActivityType> getUserActivityTopics(@PathVariable Long id) {
    return activityService.getActivityTopicsByObject(ObjectType.USER.id, id);
  }

  @GetMapping(value = "/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Activity> getUserActivities(@PathVariable Long id) {
    return activityService.getActivitiesByObject(ObjectType.USER.id, id);
  }

  @DeleteMapping(value = "/{id}/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteUserActivity(@PathVariable("id") Long activityId) {
    activityService.deleteActivityById(ObjectType.USER.id, activityId);
  }

  @PostMapping(value = "/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> addUserActivity(@PathVariable Long id, @RequestBody Activity activity) {
    return activityService.addActivityByObject(ObjectType.USER.id, id, activity);
  }

  @PutMapping(value = "/{id}/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Activity> editUserActivity(@PathVariable("id") Long activityId, @RequestBody Activity activity) {
    return activityService.editActivityByObject(ObjectType.USER.id, activityId, activity);
  }

  @PostMapping(value = "/{id}/pin/user", produces = MediaType.APPLICATION_JSON_VALUE)
  public void pinUserActivity(@PathVariable("id") Long activityId, @RequestParam Boolean pinned) {
    activityService.pinActivity(ObjectType.USER.id, activityId, pinned);
  }
}
