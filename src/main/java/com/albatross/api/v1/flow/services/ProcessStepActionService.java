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
import java.util.Map;
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

  public List<ProcessStepAction> getActionsForStep(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
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

  public void updateActionOrder(List<ProcessStepAction> actions) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    for(ProcessStepAction action : actions) {
      params.put("displayOrder", action.getDisplayOrder());
      params.put("modifiedById", currentUser.getId());
      params.put("id", action.getId());
      //save each display_order
      sqlCache.update("processStepAction.updateActionDisplayOrder", params);
    }
  }

  public ProcessStepAction updateAction(ProcessStepAction action) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("actionName", action.getActionName());
    params.put("actionTypeId", action.getActionTypeId());
    params.put("alwaysEnabled", action.getAlwaysEnabled());
    params.put("companyProcessStepStatusTypeId", action.getCompanyProcessStepStatusTypeId());
    params.put("companyProjectStatusTypeId", action.getCompanyProjectStatusTypeId());
    params.put("modifiedById", currentUser.getId());
    params.put("id", action.getId());
    params.put("multipleUses", action.getMultipleUses() != null && action.getMultipleUses());
    params.put("triggerAutomatically", action.getTriggerAutomatically() != null && action.getTriggerAutomatically());
    params.put("timeBasedTrigger", action.getTimeBasedTrigger() != null && action.getTimeBasedTrigger());

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
    if(null != action.getLogicListChanged() && action.getLogicListChanged()) {
      // archive all old logic before saving new logi
      sqlCache.update("processStepAction.archiveOldLogic", params);

      if (!action.getProcessStepLogicList().isEmpty()) {
        // handle saving logic items.
        // insert the new ones
        int count = 0;
        for (ProcessStepLogic logic : action.getProcessStepLogicList()) {
          if (null != logic.getProcessStepRequirementId() && (null == logic.getProcessStepRequirementImmutable() || !logic.getProcessStepRequirementImmutable())) {
            // update psr.immutable, if it is not already true. (don't have to do this for updates because it should already be true by now)
            HashMap<String, Object> psrParams = new HashMap<>();
            psrParams.put("id", logic.getProcessStepRequirementId());
            sqlCache.update("processStepRequirement.setImmutable", psrParams);
          }

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
    params.put("companyProcessStepStatusTypeId", action.getCompanyProcessStepStatusTypeId());
    params.put("companyProjectStatusTypeId", action.getCompanyProjectStatusTypeId());
    params.put("multipleUses", action.getMultipleUses() != null && action.getMultipleUses());
    params.put("triggerAutomatically", action.getTriggerAutomatically() != null && action.getTriggerAutomatically());
    params.put("timeBasedTrigger", action.getTimeBasedTrigger() != null && action.getTimeBasedTrigger());

    Long id = sqlCache.updateReturningId("processStepAction.insertAction", params, "id").longValue();
    return getActionById(id);
  }

  // CHILD PROCESSES
  public List<ProcessStep> getChildProcessStepsForAction(Long stepId, Long actionId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("stepId", stepId);
    params.put("actionId", actionId);

    List<ProcessStep> results = sqlCache.query("processStepAction.getChildProcessStepsForAction", params, ProcessStep.class);
//    rn add this back to the old query if i broke things by taking it out: ps.id != :stepId

    return results;
  }

  public ProcessStepActionChildProcess addChildStepToAction(Long actionId, ProcessStepActionChildProcess child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", child.getProcessStepId());
    params.put("processStepActionId", actionId);
    params.put("displayOrder", child.getDisplayOrder());
    params.put("createdById", currentUser.getId());
    params.put("companyProcessStepStatusTypeId", child.getCompanyProcessStepStatusTypeId());

    Long id = sqlCache.updateReturningId("processStepAction.addChildStepToAction", params, "id").longValue();
    return getActionChildStep(id);
  }

  public ProcessStepActionChildProcess saveChildProcessCancelledStatus(Long actionId, Long childProcessStepId, ProcessStepActionChildProcess child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("childProcessStepId", childProcessStepId);
    params.put("processStepActionId", actionId);
    params.put("companyProcessStepStatusTypeId", child.getCompanyProcessStepStatusTypeId());
    params.put("modifiedById", currentUser.getId());

    Long id = sqlCache.updateReturningId("processStepAction.saveChildProcessCancelledStatus", params, "id").longValue();
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
    params.put("companyProcessStepStatusTypeId", child.getCompanyProcessStepStatusTypeId());
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

  // CHILD FUNCTIONS
  public ProcessStepActionChildFunction addChildFunctionToAction(Long actionId, ProcessStepActionChildFunction child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyFunctionId", child.getCompanyFunctionId());
    params.put("processStepActionId", actionId);
    params.put("displayOrder", child.getDisplayOrder());
    params.put("createdById", currentUser.getId());

    Long id = sqlCache.updateReturningId("processStepAction.addChildFunctionToAction", params, "id").longValue();

    handleDynamicValueParams(child.getActionParamDynamicValues(), id);

    return getActionChildFunction(id);
  }

  public ProcessStepActionChildFunction getActionChildFunction(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProcessStepActionChildFunction> result = sqlCache.get("processStepAction.getActionChildFunction", params, new ProcessStepActionChildFunctionMapper<>(ProcessStepActionChildFunction.class, om));
    return result.orElse(null);
  }

  public void deleteChildFunctionFromAction(Long childProcessId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.getId());
    params.put("id", childProcessId);
    sqlCache.update("processStepAction.deleteActionChildFunction", params);
  }

  public void updateActionChildFunction(Long actionId, ProcessStepActionChildFunction child) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.getId());
    params.put("id", child.getId());
    params.put("displayOrder", child.getDisplayOrder());
    sqlCache.update("processStepAction.updateActionChildFunction", params);

    handleDynamicValueParams(child.getActionParamDynamicValues(), child.getId());
  }

  public void handleDynamicValueParams(List<ActionParamDynamicValue> params, Long processStepActionCompanyFunctionId) {
    if(!params.isEmpty()) {
      User currentUser = securityService.getCurrentUser();

      for(ActionParamDynamicValue p : params){
        HashMap<String, Object> dynamicParams = new HashMap<>();
        dynamicParams.put("dbFunctionParamId", p.getDbFunctionParamId());
        dynamicParams.put("processStepActionCompanyFunctionId", processStepActionCompanyFunctionId);
        dynamicParams.put("dynamicValue", p.getDynamicValue());

        if(null != p.getId()){
          dynamicParams.put("id", p.getId());
          dynamicParams.put("modifiedById", currentUser.getId());
          sqlCache.update("processStepAction.updateActionParamDynamicValue", dynamicParams);
        }else {
          dynamicParams.put("createdById", currentUser.getId());
          sqlCache.update("processStepAction.insertActionParamDynamicValue", dynamicParams);
        }
      }
    }
  }

  public List<ProcessStepActionChildFunction> getChildFunctionsWithParamValues(Long actionId, Long projectProcessStepId) {
    Map<String, Object> params = Map.of("id", actionId, "projectProcessStepId", projectProcessStepId);
    return sqlCache.query("processStepAction.getChildFunctionsByProjectProcessStepId", params, new ProcessStepActionChildFunctionMapper<>(ProcessStepActionChildFunction.class, om));
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
      TypeReference<List<ProcessStepLogic>> processStepLogicTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "processStepLogicList",
          new JsonCollectionDeserializer(processStepLogicTypeRef, objectMapper));

      TypeReference<List<ProcessStepActionChildProcess>> processStepActionChildProcessesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "processStepActionChildProcesses",
          new JsonCollectionDeserializer(processStepActionChildProcessesRef, objectMapper));

      TypeReference<List<ProcessStepActionChildFunction>> processStepActionChildFunctionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "processStepActionChildFunctions",
        new JsonCollectionDeserializer(processStepActionChildFunctionsRef, objectMapper));

      TypeReference<List<ProcessStepActionLink>> processStepActionLinksRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "processStepActionLinks",
          new JsonCollectionDeserializer(processStepActionLinksRef, objectMapper));
    }
  }

  public static class ProcessStepActionChildFunctionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepActionChildFunctionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ActionParamDynamicValue>> actionParamDynamicValuesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "actionParamDynamicValues",
        new JsonCollectionDeserializer(actionParamDynamicValuesRef, objectMapper));

      TypeReference<List<CompanyFunctionParam>> companyFunctionParamsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "companyFunctionParams", new JsonCollectionDeserializer<>(companyFunctionParamsRef, objectMapper));
    }
  }

}
