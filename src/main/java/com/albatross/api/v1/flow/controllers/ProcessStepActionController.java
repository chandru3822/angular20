package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ProcessStepAction;
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

  @RequestMapping(value = "/{actionId}/deleteChildProcessFromAction/{childProcessId}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteChildProcessFromAction(@PathVariable Long childProcessId) {
    processStepActionService.deleteChildProcessFromAction(childProcessId);
  }

  @RequestMapping(value = "", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepAction updateAction(@RequestBody ProcessStepAction action) {
    return processStepActionService.updateAction(action);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public ProcessStepAction insertAction(@RequestBody ProcessStepAction action) {
    return processStepActionService.insertAction(action);
  }

}
