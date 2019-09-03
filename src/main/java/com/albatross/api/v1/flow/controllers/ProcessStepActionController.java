package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ProcessStepAction;
import com.albatross.api.v1.flow.model.ProcessStepActionChildProcess;
import com.albatross.api.v1.flow.model.ProcessStepActionLink;
import com.albatross.api.v1.flow.services.ProcessStepActionService;
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
@RequestMapping(value = "/api/v1/flow/{companyId}/processStep/{stepId}/action")
public class ProcessStepActionController {

  @Autowired
  private ProcessStepActionService processStepActionService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepAction> getActionsForStep (@PathVariable Long companyId,
                                                    @PathVariable Long stepId) {
    return processStepActionService.getActionsForStep(companyId, stepId);
  }

  @RequestMapping(value = "/{actionId}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteAction(@PathVariable Long actionId) {
    processStepActionService.deleteAction(actionId);
  }

  @RequestMapping(value = "", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepAction updateAction(@RequestBody ProcessStepAction action) {
    return processStepActionService.updateAction(action);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepAction insertAction(@RequestBody ProcessStepAction action) {
    return processStepActionService.insertAction(action);
  }

  // child process steps
  @RequestMapping(value = "/{actionId}/addChildStepToAction", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepActionChildProcess addChildStepToAction(@PathVariable Long actionId,
                                                            @RequestBody ProcessStepActionChildProcess child) {
    return processStepActionService.addChildStepToAction(actionId, child);
  }

  @RequestMapping(value = "/{actionId}/deleteChildStep/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteChildProcessFromAction(@PathVariable Long id) {
    processStepActionService.deleteChildProcessFromAction(id);
  }

  @RequestMapping(value = "/{actionId}/updateActionChildStep", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateActionChildStep(@PathVariable Long actionId,
                                    @RequestBody ProcessStepActionChildProcess child) {
    processStepActionService.updateActionChildStep(actionId, child);
  }

  // child links
  @RequestMapping(value = "/{actionId}/addLinkToAction", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepActionLink addLinkToAction(@PathVariable Long actionId,
                                               @RequestBody ProcessStepActionLink link) {
    return processStepActionService.addLinkToAction(actionId, link);
  }

  @RequestMapping(value = "/{actionId}/deleteLinkFromAction/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteLink(@PathVariable Long id) {
    processStepActionService.deleteLinkFromAction(id);
  }
}
