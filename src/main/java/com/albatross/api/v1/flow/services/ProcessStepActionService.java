package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class ProcessStepActionService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<ProcessStepAction> getActionsForStep(Long companyId, Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("processStepId", processStepId);
    params.put("id", null);
    //@randa come back to this. i was annoyed to have to keep 2 queries up-to-date when they were basically doing the same thing. (single select by id, vs list select by process_step_id) but this requires both calls to pass in a null param, not sure i like this
    List<ProcessStepAction> results = sqlCache.query("processStepAction.getActionsForStep", params, new ProcessStepActionMapper<>(ProcessStepAction.class, om));
    return results;
  }

  public void deleteAction(Long actionId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.getId());
    params.put("actionId", actionId);
    sqlCache.update("processStepAction.deleteAction", params);
  }

  public ProcessStepAction getActionById(Long id) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("processStepId", null);
    //@randa come back to this. i was annoyed to have to keep 2 queries up-to-date when they were basically doing the same thing. but this requires both calls to pass in a null param, not sure i like this
    Optional<ProcessStepAction> result = sqlCache.get("processStepAction.getActionsForStep", params, new ProcessStepActionMapper<>(ProcessStepAction.class, om));

    return result.orElse(null);
  }

  public ProcessStepAction updateAction(ProcessStepAction action) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("actionName", action.getActionName());
    params.put("actionTypeId", action.getActionTypeId());
    params.put("processStepStatusTypeId", action.getProcessStepStatusTypeId());
    params.put("modifiedById", currentUser.getId());
    params.put("id", action.getId());

    Long id = sqlCache.updateReturningId("processStepAction.updateAction", params, "id").longValue();

    // delete childProcessSteps if it is a link (if they changed the type)
    if(action.getActionTypeId() == 1L && !action.getProcessStepActionChildProcesses().isEmpty()) {
      for(ProcessStepActionChildProcess child : action.getProcessStepActionChildProcesses()){
        deleteChildProcessFromAction(child.getId());
      }
    }
    // delete childLinks if it is a button (if they changed the type)
    if(action.getActionTypeId() == 2L && !action.getProcessStepActionLinks().isEmpty()) {
      for(ProcessStepActionLink link : action.getProcessStepActionLinks()){
        deleteLinkFromAction(link.getId());
      }
    }

    if(!action.getProcessStepLogicList().isEmpty()) {
      // handle saving logic items.
      // archive all old ones
      sqlCache.update("processStepAction.archiveOldLogic", params);
      // insert the new ones
      int count = 0;
      for(ProcessStepLogic logic : action.getProcessStepLogicList()) {
        HashMap<String, Object> logicParams = new HashMap<>();
        logicParams.put("id", action.getId());
        logicParams.put("processStepRequirementId", logic.getProcessStepRequirementId());
        logicParams.put("operationTypeId", logic.getOperationTypeId());
        logicParams.put("sqlOrder", count);
        logicParams.put("createdById", currentUser.getId());
        sqlCache.update("processStepAction.insertLogic", logicParams);
        count++;
      }
    }
    return getActionById(id);
  }

  public ProcessStepAction insertAction(ProcessStepAction action) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("actionName", action.getActionName());
    params.put("actionTypeId", action.getActionTypeId());
    params.put("createdById", currentUser.getId());
    params.put("processStepId", action.getProcessStepId());
    params.put("processStepStatusTypeId", action.getProcessStepStatusTypeId());

    Long id = sqlCache.updateReturningId("processStepAction.insertAction", params, "id").longValue();
    return getActionById(id);
  }

  // CHILD PROCESSES
  public List<ProcessStep> getChildProcessStepsForAction(Long companyId, Long stepId, Long actionId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("stepId", stepId);
    params.put("actionId", actionId);

    List<ProcessStep> results = sqlCache.query("processStepAction.getChildProcessStepsForAction", params, ProcessStep.class);
    return results;
  }

  public ProcessStepActionChildProcess addChildStepToAction(Long actionId, ProcessStepActionChildProcess child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", child.getProcessStepId());
    params.put("processStepActionId", actionId);
    params.put("triggerAutomatically", child.getTriggerAutomatically());
    params.put("displayOrder", child.getDisplayOrder());
    params.put("createdById", currentUser.getId());

    Long id = sqlCache.updateReturningId("processStepAction.addChildStepToAction", params, "id").longValue();
    return getActionChildStep(id);
  }

  public ProcessStepActionChildProcess getActionChildStep(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProcessStepActionChildProcess> result = sqlCache.get("processStepAction.getActionChildStep", params, ProcessStepActionChildProcess.class);
    return result.orElse(null);
  }

  public void deleteChildProcessFromAction(Long childProcessId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.getId());
    params.put("id", childProcessId);
    sqlCache.update("processStepAction.deleteActionChildStep", params);
  }

  public void updateActionChildStep(Long actionId, ProcessStepActionChildProcess child) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.getId());
    params.put("id", child.getId());
    params.put("displayOrder", child.getDisplayOrder());
    params.put("triggerAutomatically", child.getTriggerAutomatically());
    sqlCache.update("processStepAction.updateActionChildStep", params);
  }

  // CHILD LINKS
  public ProcessStepActionLink addLinkToAction(Long actionId, ProcessStepActionLink child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("linkId", child.getLinkId());
    params.put("processStepActionId", actionId);
    params.put("createdById", currentUser.getId());

    Long id = sqlCache.updateReturningId("processStepAction.addLinkToAction", params, "id").longValue();
    return getActionChildLink(id);
  }

  public ProcessStepActionLink getActionChildLink(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProcessStepActionLink> result = sqlCache.get("processStepAction.getActionChildLink", params, ProcessStepActionLink.class);
    return result.orElse(null);
  }

  public void deleteLinkFromAction(Long childLinkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.getId());
    params.put("id", childLinkId);
    sqlCache.update("processStepAction.deleteLinkFromAction", params);
  }


  // MAPPER
  public static class ProcessStepActionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepActionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ProcessStepLogic>> processStepLogicTypeRef = new TypeReference<List<ProcessStepLogic>>() {};
      bw.registerCustomEditor(List.class, "processStepLogicList",
          new JsonCollectionDeserializer(processStepLogicTypeRef, objectMapper));

      TypeReference<List<ProcessStepActionChildProcess>> processStepActionChildProcessesRef = new TypeReference<List<ProcessStepActionChildProcess>>() {};
      bw.registerCustomEditor(List.class, "processStepActionChildProcesses",
          new JsonCollectionDeserializer(processStepActionChildProcessesRef, objectMapper));

      TypeReference<List<ProcessStepActionLink>> processStepActionLinksRef = new TypeReference<List<ProcessStepActionLink>>() {};
      bw.registerCustomEditor(List.class, "processStepActionLinks",
          new JsonCollectionDeserializer(processStepActionLinksRef, objectMapper));
    }
  }

}
