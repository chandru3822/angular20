package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.processStep.*;
import com.albatross.api.v1.flow.services.ProcessStepActionService;
import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/processStep/{stepId}/action")
public class ProcessStepActionController {

  private final ProcessStepActionService processStepActionService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepAction> getActionsForStep (@PathVariable Long stepId) {
    return processStepActionService.getActionsForStep(stepId);
  }

  @DeleteMapping(value = "/{actionId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteAction(@PathVariable Long actionId) {
    processStepActionService.deleteAction(actionId);
  }

  @PutMapping(value = "/{id}/duplicate", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepAction duplicateAction(@PathVariable Long id) {
    return processStepActionService.duplicateAction(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepAction updateAction(@RequestBody ProcessStepAction action) {
    return processStepActionService.updateAction(action);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepAction insertAction(@RequestBody ProcessStepAction action) {
    return processStepActionService.insertAction(action);
  }

  @GetMapping(value = "/{actionId}/logicString", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getActionLogicString (@PathVariable Long actionId) {
    return processStepActionService.getActionLogicString(actionId);
  }

  // child process steps

  @GetMapping(value = "/{actionId}/childProcessSteps", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> getChildProcessStepsForAction (@PathVariable Long stepId, @PathVariable Long actionId) {
    return processStepActionService.getChildProcessStepsForAction(stepId, actionId);
  }

  @PostMapping(value = "/{actionId}/addChildStepToAction", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepActionChildProcess addChildStepToAction(@PathVariable Long actionId,
                                                            @RequestBody ProcessStepActionChildProcess child) {
    return processStepActionService.addChildStepToAction(actionId, child);
  }

  @PutMapping(value = "/{actionId}/child/{childProcessStepId}/status", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepActionChildProcess saveChildProcessCancelledStatus(@PathVariable Long actionId,
                                                                       @PathVariable Long childProcessStepId,
                                                                       @RequestBody ProcessStepActionChildProcess child) {
    return processStepActionService.saveChildProcessCancelledStatus(actionId, childProcessStepId, child);
  }

  @PutMapping(value = "/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateActionOrder(@RequestBody List<ProcessStepAction> actions) {
    processStepActionService.updateActionOrder(actions);
  }

  @DeleteMapping(value = "/{actionId}/deleteChildStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteChildProcessFromAction(@PathVariable Long id) {
    processStepActionService.deleteChildProcessFromAction(id);
  }

  @PutMapping(value = "/{actionId}/updateActionChildStep", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateActionChildStep(@PathVariable Long actionId,
                                    @RequestBody ProcessStepActionChildProcess child) {
    processStepActionService.updateActionChildStep(actionId, child);
  }

  // child links
  @PostMapping(value = "/{actionId}/addLinkToAction", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepActionLink addLinkToAction(@PathVariable Long actionId,
                                               @RequestBody ProcessStepActionLink link) {
    return processStepActionService.addLinkToAction(actionId, link);
  }

  @DeleteMapping(value = "/{actionId}/deleteLinkFromAction/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteLink(@PathVariable Long id) {
    processStepActionService.deleteLinkFromAction(id);
  }

  // child functions

  @PostMapping(value = "/{actionId}/addChildFunctionToAction", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepActionChildFunction addChildFunctionToAction(@PathVariable Long actionId,
                                                                 @RequestBody ProcessStepActionChildFunction child) {
    return processStepActionService.addChildFunctionToAction(actionId, child);
  }

  @DeleteMapping(value = "/{actionId}/deleteChildFunction/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteChildFunctionFromAction(@PathVariable Long id) {
    processStepActionService.deleteChildFunctionFromAction(id);
  }

  @PutMapping(value = "/{actionId}/updateActionChildFunction", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateActionChildFunction(@PathVariable Long actionId,
                                        @RequestBody ProcessStepActionChildFunction child) {
    processStepActionService.updateActionChildFunction(actionId, child);
  }
}
