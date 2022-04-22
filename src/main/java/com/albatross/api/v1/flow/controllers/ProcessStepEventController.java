package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.processStep.*;
import com.albatross.api.v1.flow.services.ProcessStepEventService;
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
@RequestMapping(value = "/api/v1/flow/processStep/{stepId}/event")
public class ProcessStepEventController {

  private final ProcessStepEventService processStepEventService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepEvent> getStepEvents (@PathVariable Long stepId) {
    return processStepEventService.getStepEvents(stepId);
  }

  @GetMapping(value = "/{psEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepEvent> getEventDetails (@PathVariable Long psEventId) {
    return processStepEventService.getProcessStepEvent(psEventId);
  }

  @GetMapping(value = "/available", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepEvent> getAvailableEventsForStep (@PathVariable Long stepId) {
    return processStepEventService.getAvailableEventsForStep(stepId);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepEvent> addEventToStep (@PathVariable Long stepId,
                                                    @RequestBody ProcessStepEvent processStepEvent) {
    return processStepEventService.addEventToStep(stepId, processStepEvent);
  }

  @PutMapping(value = "/{eventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateStepEvent (@PathVariable Long stepId,
                               @PathVariable Long eventId,
                               @RequestBody ProcessStepEvent processStepEvent) {
    processStepEventService.updateStepEvent(stepId, eventId, processStepEvent);
  }

  @PutMapping(value = "/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateEventOrder(@RequestBody List<ProcessStepEvent> events) {
    processStepEventService.updateEventOrder(events);
  }

  @DeleteMapping(value = "/{processStepEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteEventFromStep (@PathVariable Long processStepEventId) {
    processStepEventService.deleteEventFromStep(processStepEventId);
  }

  //this endpoint is specifically made for the BR mobile app, BUT it is generic and anyone could use it so i put it here
  @GetMapping(value = "/{processStepEventId}/userCanEditStartTime", produces = MediaType.APPLICATION_JSON_VALUE)
  public Boolean userCanEditStartTime(@PathVariable Long processStepEventId) {
    return processStepEventService.userCanEditStartTime(processStepEventId);
  }

  //event actions
  @PostMapping(value = "/{eventId}/action", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepEventAction> addStepEventAction (@PathVariable Long stepId,
                                                              @PathVariable Long eventId,
                                                              @RequestBody ProcessStepEventAction processStepEventAction) {
    return processStepEventService.saveStepEventAction(stepId, eventId, processStepEventAction);
  }

  @PutMapping(value = "/{eventId}/action/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateEventActionOrder(@RequestBody List<ProcessStepEventAction> actions) {
    processStepEventService.updateEventActionOrder(actions);
  }

  @DeleteMapping(value = "/{eventId}/action/{actionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteStepEventAction (@PathVariable Long actionId) {
    processStepEventService.deleteActionFromEvent(actionId);
  }

  // event action child functions

  @PostMapping(value = "/{eventId}/action/{actionId}/addChildFunctionToAction", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepEventActionChildFunction addChildFunctionToAction(@PathVariable Long actionId,
                                                                      @RequestBody ProcessStepEventActionChildFunction child) {
    return processStepEventService.addChildFunctionToAction(actionId, child);
  }

  @DeleteMapping(value = "/{eventId}/action/{actionId}/deleteChildFunction/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteChildFunctionFromAction(@PathVariable Long id) {
    processStepEventService.deleteChildFunctionFromAction(id);
  }

  @PutMapping(value = "/{eventId}/action/{actionId}/updateActionChildFunction", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateActionChildFunction(@PathVariable Long actionId,
                                        @RequestBody ProcessStepActionChildFunction child) {
    processStepEventService.updateActionChildFunction(actionId, child);
  }

  //fields
  @PutMapping(value = "/{eventId}/action/{actionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Long updateRequiredFieldStatus (@PathVariable Long actionId,
                                         @RequestBody ProcessStepEventActionField processStepEventActionField) {
    return processStepEventService.updateRequiredFieldStatus(actionId, processStepEventActionField);
  }

}
