package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.ProcessStepEvent;
import com.albatross.api.v1.flow.model.ProcessStepEventAction;
import com.albatross.api.v1.flow.model.ProcessStepEventActionRequiredField;
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

  @DeleteMapping(value = "/{processStepEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteEventFromStep (@PathVariable Long processStepEventId) {
    processStepEventService.deleteEventFromStep(processStepEventId);
  }

  //event actions
  @PostMapping(value = "/{eventId}/action", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepEventAction> addStepEventAction (@PathVariable Long stepId,
                                 @PathVariable Long eventId,
                                 @RequestBody ProcessStepEventAction processStepEventAction) {
    return processStepEventService.addStepEventAction(stepId, eventId, processStepEventAction);
  }

  @DeleteMapping(value = "/{eventId}/action/{actionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteStepEventAction (@PathVariable Long actionId) {
    processStepEventService.deleteActionFromEvent(actionId);
  }

  @PostMapping(value = "/{eventId}/action/{actionId}/saveRequiredField/{cfgaId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepEventActionRequiredField> addRequiredField(@PathVariable Long eventId,
                                                                        @PathVariable Long actionId,
                                                                        @PathVariable Long cfgaId) {
    return processStepEventService.addRequiredFieldToAction(eventId, actionId, cfgaId);
  }

  @DeleteMapping(value = "/{eventId}/action/{actionId}/requiredField/{requiredFieldId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteRequiredField(@PathVariable Long eventId,
                                                                        @PathVariable Long actionId,
                                                                        @PathVariable Long requiredFieldId) {
    processStepEventService.deleteRequiredField(eventId, actionId, requiredFieldId);
  }

  //custom field stuff
  @GetMapping(value = "/{eventId}/action/{actionId}/availableFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomField> getAvailableFieldsForEvent(@PathVariable Long eventId,
                                                      @PathVariable Long actionId) {
    return processStepEventService.getAvailableFieldsForEvent(eventId, actionId);
  }

}
