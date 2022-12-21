package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.function.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.processStep.*;
import com.albatross.api.v1.flow.queries.ProcessStepActionQuery;
import com.albatross.api.v1.flow.queries.ProcessStepRequirementQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProcessStepActionService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<ProcessStepAction> getActionsForStep(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("id", null);
    // @randa come back to this. i was annoyed to have to keep 2 queries up-to-date when they were
    // basically doing the same thing. (single select by id, vs list select by process_step_id) but
    // this requires both calls to pass in a null param, not sure i like this
    return sqlCache.queryBySql(
      ProcessStepActionQuery.getActionsForStep,
        params,
        new ProcessStepActionMapper<>(ProcessStepAction.class, om));
  }

  public String getActionLogicString(Long actionId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("actionId", actionId);
    Optional<String> logicString = sqlCache.queryForObjectOptionalBySql(ProcessStepActionQuery.actionLogicString, params, String.class);
    return logicString.orElse("");
  }

  public void deleteAction(Long actionId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("actionId", actionId);
    sqlCache.updateBySql(ProcessStepActionQuery.deleteAction, params);
  }

  public ProcessStepAction getActionById(Long id) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("processStepId", null);
    // @randa come back to this. i was annoyed to have to keep 2 queries up-to-date when they were
    // basically doing the same thing. but this requires both calls to pass in a null param, not
    // sure i like this
    return sqlCache
        .getBySql(
          ProcessStepActionQuery.getActionsForStep,
            params,
            new ProcessStepActionMapper<>(ProcessStepAction.class, om))
        .orElse(null);
  }

  public void updateActionOrder(List<ProcessStepAction> actions) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    for (ProcessStepAction action : actions) {
      params.put("displayOrder", action.getDisplayOrder());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("id", action.getId());
      // save each display_order
      sqlCache.updateBySql(ProcessStepActionQuery.updateActionDisplayOrder, params);
    }
  }

  public ProcessStepAction duplicateAction(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("actionId", id);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    Long newActionId = sqlCache.queryForObjectBySql(ProcessStepActionQuery.duplicateAction, params, Long.class);
    return getActionById(newActionId);
  }


  public ProcessStepAction updateAction(ProcessStepAction action) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("actionName", action.getActionName());
    params.put("actionTypeId", action.getActionTypeId());
    params.put("alwaysEnabled", action.getAlwaysEnabled());
    params.put("content", action.getContent());
    params.put("color", action.getColor());
    params.put("bgColor", action.getBgColor());
    params.put("companyProcessStepStatusTypeId", action.getCompanyProcessStepStatusTypeId());
    params.put("companyProjectStatusTypeId", action.getCompanyProjectStatusTypeId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", action.getId());
    params.put(
        "removeProcessStepOwner",
        action.getRemoveProcessStepOwner() != null && action.getRemoveProcessStepOwner());
    params.put("multipleUses", action.getMultipleUses() != null && action.getMultipleUses());
    params.put(
        "triggerAutomatically",
        action.getTriggerAutomatically() != null && action.getTriggerAutomatically());
    params.put(
        "timeBasedTrigger", action.getTimeBasedTrigger() != null && action.getTimeBasedTrigger());
    params.put("hideFromMobile", action.getHideFromMobile() != null && action.getHideFromMobile());
    params.put("hideFromWeb", action.getHideFromWeb() != null && action.getHideFromWeb());

    Long id =
        sqlCache.updateBySqlReturningId(ProcessStepActionQuery.updateAction, params, "id").longValue();

    // delete childProcessSteps if it is a link (if they changed the type)
    if (action.getActionTypeId() == 1L && !action.getProcessStepActionChildProcesses().isEmpty()) {
      for (ProcessStepActionChildProcess child : action.getProcessStepActionChildProcesses()) {
        deleteChildProcessFromAction(child.getId());
      }
    }
    // delete childLinks if it is a button (if they changed the type)
    if (action.getActionTypeId() == 2L && !action.getProcessStepActionLinks().isEmpty()) {
      for (ProcessStepActionLink link : action.getProcessStepActionLinks()) {
        deleteLinkFromAction(link.getId());
      }
    }
    if (null != action.getLogicListChanged() && action.getLogicListChanged()) {
      // archive all old logic before saving new logi
      sqlCache.updateBySql(ProcessStepActionQuery.archiveOldLogic, params);

      if (!action.getProcessStepLogicList().isEmpty()) {
        // handle saving logic items.
        // insert the new ones
        int count = 0;
        for (ProcessStepLogic logic : action.getProcessStepLogicList()) {
          if (null != logic.getProcessStepRequirementId()
              && (null == logic.getProcessStepRequirementImmutable()
                  || !logic.getProcessStepRequirementImmutable())) {
            // update psr.immutable, if it is not already true. (don't have to do this for updates
            // because it should already be true by now)
            HashMap<String, Object> psrParams = new HashMap<>();
            psrParams.put("id", logic.getProcessStepRequirementId());
            sqlCache.updateBySql(ProcessStepRequirementQuery.setImmutable, psrParams);
          }

          HashMap<String, Object> logicParams = new HashMap<>();
          logicParams.put("id", action.getId());
          logicParams.put("processStepRequirementId", logic.getProcessStepRequirementId());
          logicParams.put("operationTypeId", logic.getOperationTypeId());
          logicParams.put("sqlOrder", count);
          logicParams.put("createdById", currentUser.trueUserId());
          sqlCache.updateBySql(ProcessStepActionQuery.insertLogic, logicParams);
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
    params.put("createdById", currentUser.trueUserId());
    params.put("processStepId", action.getProcessStepId());
    params.put("content", action.getContent());
    params.put("color", action.getColor());
    params.put("bgColor", action.getBgColor());
    params.put("companyProcessStepStatusTypeId", action.getCompanyProcessStepStatusTypeId());
    params.put("companyProjectStatusTypeId", action.getCompanyProjectStatusTypeId());
    params.put(
        "removeProcessStepOwner",
        action.getRemoveProcessStepOwner() != null && action.getRemoveProcessStepOwner());
    params.put("multipleUses", action.getMultipleUses() != null && action.getMultipleUses());
    params.put(
        "triggerAutomatically",
        action.getTriggerAutomatically() != null && action.getTriggerAutomatically());
    params.put(
        "timeBasedTrigger", action.getTimeBasedTrigger() != null && action.getTimeBasedTrigger());
    params.put("hideFromMobile", action.getHideFromMobile() != null && action.getHideFromMobile());
    params.put("hideFromWeb", action.getHideFromWeb() != null && action.getHideFromWeb());

    Long id =
        sqlCache.updateBySqlReturningId(ProcessStepActionQuery.insertAction, params, "id").longValue();
    return getActionById(id);
  }

  // CHILD PROCESSES
  public List<ProcessStep> getChildProcessStepsForAction(Long stepId, Long actionId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("stepId", stepId);
    params.put("actionId", actionId);

    //    rn add this back to the old query if i broke things by taking it out: ps.id != :stepId

    return sqlCache.queryBySql(
      ProcessStepActionQuery.getChildProcessStepsForAction, params, ProcessStep.class);
  }

  public ProcessStepActionChildProcess addChildStepToAction(
      Long actionId, ProcessStepActionChildProcess child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", child.getProcessStepId());
    params.put("processStepActionId", actionId);
    params.put("displayOrder", child.getDisplayOrder());
    params.put("createdById", currentUser.trueUserId());
    params.put("companyProcessStepStatusTypeId", child.getExistingCompanyProcessStepStatusTypeId());
    params.put(
        "existingCompanyProcessStepStatusTypeId",
        child.getExistingCompanyProcessStepStatusTypeId());
    params.put(
        "initialCompanyProcessStepStatusTypeId", child.getInitialCompanyProcessStepStatusTypeId());

    Long id =
        sqlCache
            .updateBySqlReturningId(ProcessStepActionQuery.addChildStepToAction, params, "id")
            .longValue();
    return getActionChildStep(id);
  }

  public ProcessStepActionChildProcess saveChildProcessCancelledStatus(
      Long actionId, Long childProcessStepId, ProcessStepActionChildProcess child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("childProcessStepId", childProcessStepId);
    params.put("processStepActionId", actionId);
    params.put(
        "existingCompanyProcessStepStatusTypeId",
        child.getExistingCompanyProcessStepStatusTypeId());
    params.put(
        "initialCompanyProcessStepStatusTypeId", child.getInitialCompanyProcessStepStatusTypeId());
    params.put("modifiedById", currentUser.trueUserId());

    Long id =
        sqlCache
            .updateBySqlReturningId(ProcessStepActionQuery.saveChildProcessStatuses, params, "id")
            .longValue();
    return getActionChildStep(id);
  }

  public ProcessStepActionChildProcess getActionChildStep(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProcessStepActionChildProcess> result =
        sqlCache.getBySql(
          ProcessStepActionQuery.getActionChildStep, params, ProcessStepActionChildProcess.class);
    return result.orElse(null);
  }

  public void deleteChildProcessFromAction(Long childProcessId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", childProcessId);

    sqlCache.updateBySql(ProcessStepActionQuery.deleteActionChildStep, params);
  }

  public void updateActionChildStep(Long actionId, ProcessStepActionChildProcess child) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", child.getId());
    params.put("displayOrder", child.getDisplayOrder());
    params.put(
        "existingCompanyProcessStepStatusTypeId",
        child.getExistingCompanyProcessStepStatusTypeId());
    params.put(
        "initialCompanyProcessStepStatusTypeId", child.getInitialCompanyProcessStepStatusTypeId());
    sqlCache.updateBySql(ProcessStepActionQuery.updateActionChildStep, params);
  }

  // CHILD LINKS
  public ProcessStepActionLink addLinkToAction(Long actionId, ProcessStepActionLink child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("linkId", child.getLinkId());
    params.put("processStepActionId", actionId);
    params.put("createdById", currentUser.trueUserId());

    Long id =
        sqlCache.updateBySqlReturningId(ProcessStepActionQuery.addLinkToAction, params, "id").longValue();
    return getActionChildLink(id);
  }

  public ProcessStepActionLink getActionChildLink(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
        .getBySql(ProcessStepActionQuery.getActionChildLink, params, ProcessStepActionLink.class)
        .orElse(null);
  }

  public void deleteLinkFromAction(Long childLinkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", childLinkId);
    sqlCache.updateBySql(ProcessStepActionQuery.deleteLinkFromAction, params);
  }

  // CHILD FUNCTIONS
  public ProcessStepActionChildFunction addChildFunctionToAction(
      Long actionId, ProcessStepActionChildFunction child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyFunctionId", child.getCompanyFunctionId());
    params.put("processStepActionId", actionId);
    params.put("displayOrder", child.getDisplayOrder());
    params.put("createdById", currentUser.trueUserId());

    Long id =
        sqlCache
            .updateBySqlReturningId(ProcessStepActionQuery.addChildFunctionToAction, params, "id")
            .longValue();

    handleDynamicValueParams(child.getActionParamDynamicValues(), id, null);

    return getActionChildFunction(id);
  }

  public ProcessStepActionChildFunction getActionChildFunction(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
        .getBySql(ProcessStepActionQuery.getActionChildFunction,
            params,
            new ProcessStepActionChildFunctionMapper<>(ProcessStepActionChildFunction.class, om))
        .orElse(null);
  }

  public void deleteChildFunctionFromAction(Long childProcessId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", childProcessId);
    sqlCache.updateBySql(ProcessStepActionQuery.deleteActionChildFunction, params);
  }

  public void updateActionChildFunction(Long actionId, ProcessStepActionChildFunction child) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", child.getId());
    params.put("displayOrder", child.getDisplayOrder());
    sqlCache.updateBySql(ProcessStepActionQuery.updateActionChildFunction, params);

    handleDynamicValueParams(child.getActionParamDynamicValues(), child.getId(), null);
  }

  //child sms action stuff
  public ProcessStepActionChildSmsTemplate addSmsToAction(Long actionId, ProcessStepActionChildSmsTemplate child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("messageTemplateId", child.getMessageTemplateId());
    params.put("teamIds", child.getTeamIds());
    params.put("processStepActionId", actionId);
    params.put("createdById", currentUser.trueUserId());

    Long id =
      sqlCache
        .updateBySqlReturningId(ProcessStepActionQuery.addSmsToAction, params, "id")
        .longValue();


    return getActionChildSms(id);
  }

  public ProcessStepActionChildSmsTemplate getActionChildSms(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
      .getBySql(
        ProcessStepActionQuery.getActionChildSms,
        params,
        new ProcessStepActionChildSmsTemplateMapper<>(ProcessStepActionChildSmsTemplate.class, om))
      .orElse(null);
  }
  public void deleteSmsFromAction(Long childSmsId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", childSmsId);
    sqlCache.updateBySql(ProcessStepActionQuery.deleteSmsFromAction, params);
  }

  public List<ProcessStepActionChildSmsTemplate> getChildSmsTemplates(Long actionId) {
    Map<String, Object> params =
      Map.of("processStepActionId", actionId);
    return sqlCache.queryBySql(
      ProcessStepActionQuery.getChildSmsTemplatesByActionId,
      params,
      new ProcessStepActionChildSmsTemplateMapper<>(ProcessStepActionChildSmsTemplate.class, om));
  }


  public void handleDynamicValueParams(List<ActionParamDynamicValue> params, Long processStepActionCompanyFunctionId, Long processStepEventActionCompanyFunctionId) {
    if(!params.isEmpty()) {
      User currentUser = securityService.getCurrentUser();

      for (ActionParamDynamicValue p : params) {
        HashMap<String, Object> dynamicParams = new HashMap<>();
        dynamicParams.put("dbFunctionParamId", p.getDbFunctionParamId());
        dynamicParams.put("processStepActionCompanyFunctionId", processStepActionCompanyFunctionId);
        dynamicParams.put("processStepEventActionCompanyFunctionId", processStepEventActionCompanyFunctionId);
        dynamicParams.put("dynamicValue", p.getDynamicValue());

        if (null != p.getId()) {
          dynamicParams.put("id", p.getId());
          dynamicParams.put("modifiedById", currentUser.trueUserId());
          sqlCache.updateBySql(ProcessStepActionQuery.updateActionParamDynamicValue, dynamicParams);
        } else {
          dynamicParams.put("createdById", currentUser.trueUserId());
          sqlCache.updateBySql(ProcessStepActionQuery.insertActionParamDynamicValue, dynamicParams);
        }
      }
    }
  }

  public List<ProcessStepActionChildFunction> getChildFunctionsWithParamValues(
      Long actionId, Long projectProcessStepId) {
    Map<String, Object> params =
        Map.of("id", actionId, "projectProcessStepId", projectProcessStepId);
    return sqlCache.queryBySql(
      ProcessStepActionQuery.getChildFunctionsByProjectProcessStepId,
        params,
        new ProcessStepActionChildFunctionMapper<>(ProcessStepActionChildFunction.class, om));
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
      bw.registerCustomEditor(
          List.class,
          "processStepLogicList",
          new JsonCollectionDeserializer(processStepLogicTypeRef, objectMapper));

      TypeReference<List<ProcessStepActionChildProcess>> processStepActionChildProcessesRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "processStepActionChildProcesses",
          new JsonCollectionDeserializer(processStepActionChildProcessesRef, objectMapper));

      TypeReference<List<ProcessStepActionChildFunction>> processStepActionChildFunctionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "processStepActionChildFunctions",
          new JsonCollectionDeserializer(processStepActionChildFunctionsRef, objectMapper));

      TypeReference<List<ProcessStepActionChildSmsTemplate>> processStepActionChildSmsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "processStepActionChildSmsTemplates",
          new JsonCollectionDeserializer(processStepActionChildSmsRef, objectMapper));

      TypeReference<List<ProcessStepActionLink>> processStepActionLinksRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "processStepActionLinks",
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
      TypeReference<List<ActionParamDynamicValue>> actionParamDynamicValuesRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "actionParamDynamicValues",
          new JsonCollectionDeserializer(actionParamDynamicValuesRef, objectMapper));

      TypeReference<List<CompanyFunctionParam>> companyFunctionParamsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "companyFunctionParams",
          new JsonCollectionDeserializer<>(companyFunctionParamsRef, objectMapper));
    }
  }

  public static class ProcessStepActionChildSmsTemplateMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepActionChildSmsTemplateMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Long>> teamIdsTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "teamIds",
        new JsonCollectionDeserializer(teamIdsTypeRef, objectMapper));

      TypeReference<List<MessageTeam>> teamsTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "teams",
        new JsonCollectionDeserializer(teamsTypeRef, objectMapper));
    }
  }
}
