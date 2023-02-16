package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.WhiteListType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.function.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.processStep.*;
import com.albatross.api.v1.flow.queries.ProcessStepEventQuery;
import com.albatross.api.v1.flow.queries.ProcessStepEventRequirementQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@PreAuthorize("hasFeatureAccess('PROCESS_STEPS')")
@RequiredArgsConstructor
public class ProcessStepEventService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final ProcessStepActionService processStepActionService;

  public List<ProcessStepEvent> getStepEvents(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    return sqlCache.queryBySql(ProcessStepEventQuery.getStepEvents, params, new ProcessStepEventMapper<>(ProcessStepEvent.class, om));
  }

  public List<ProcessStepEvent> getAvailableEventsForStep(Long processStepId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("companyId", currentUser.getCompanyId());
    return sqlCache.queryBySql(ProcessStepEventQuery.getAvailableEventsForStep, params, new ProcessStepEventMapper<>(ProcessStepEvent.class, om));
  }

  public Optional<ProcessStepEvent> getProcessStepEvent(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<ProcessStepEvent> result = sqlCache.getBySql(ProcessStepEventQuery.get, params, new ProcessStepEventMapper<>(ProcessStepEvent.class, om));
    return result;
  }

  public Optional<ProcessStepEvent> addEventToStep(Long processStepId, ProcessStepEvent processStepEvent) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("createdById", currentUser.trueUserId());
    params.put("eventId", processStepEvent.getEventId());
    params.put("initialCompanyEventStatusTypeId", processStepEvent.getInitialCompanyEventStatusTypeId());
    Long id = sqlCache.updateBySqlReturningId(ProcessStepEventQuery.addEventToStep, params, "id").longValue();
    return getProcessStepEvent(id);
  }

  public void updateStepEvent(Long processStepId, Long eventId, ProcessStepEvent processStepEvent) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("initialCompanyEventStatusTypeId", processStepEvent.getInitialCompanyEventStatusTypeId());
    params.put("userId", currentUser.trueUserId());
    params.put("eventId", eventId);
    sqlCache.updateBySql(ProcessStepEventQuery.updateStepEvent, params);
  }

  public void updateEventOrder(List<ProcessStepEvent> events) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    for (ProcessStepEvent event : events) {
      params.put("displayOrder", event.getDisplayOrder());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("id", event.getId());
      // save each display_order
      sqlCache.updateBySql(ProcessStepEventQuery.updateDisplayOrder, params);
    }
  }

  public void saveProcessStepEventReadonlyWhiteList(ProcessStepEvent processStepEvent, Boolean savePositions){
      User currentUser = securityService.getCurrentUser();

      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", currentUser.trueUserId());
      params.put("companyId", currentUser.getCompanyId());
      params.put("processStepEventId", processStepEvent.getId());
      params.put("readOnly", processStepEvent.getReadonly());
      params.put("eventId", processStepEvent.getEventId());
      params.put("processStepId", processStepEvent.getProcessStepId());
      params.put("whiteListTypeId", WhiteListType.PROCESS_STEP_EVENT_READ_ONLY.id);

      sqlCache.updateBySql(ProcessStepEventQuery.saveReadOnly, params);

      if(!processStepEvent.getReadonly() || processStepEvent.getReadonlyWhiteListPositions().isEmpty()){
          //this means they removed ALL white listed positions
          sqlCache.updateBySql(ProcessStepEventQuery.archiveAllWhiteListPositionsForPSEvent, params);
      } else {
          List<Long> positionIdsUsed = processStepEvent.getReadonlyWhiteListPositions().stream()
                  .map(WhiteListedPosition::getPositionId)
                  .collect(Collectors.toList());
          params.put("positionIdsUsed", positionIdsUsed);
          //archive any positions that are no longer in the list
          sqlCache.updateBySql(ProcessStepEventQuery.archiveWhiteListPositionsNoLongerUsed, params);

          //insert any positions that are new to the list
          for (Long whiteListPositionId : positionIdsUsed) {
              params.put("positionId", whiteListPositionId);
              //this insert checks if there is already a non-archived row with the same values
              sqlCache.updateBySql(ProcessStepEventQuery.insertWhiteListPosition, params);
          }

      }
  }

  public Boolean userCanEditStartTime(Long processStepEventId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepEventId", processStepEventId);

    List<Long> whiteListedPositionIds = sqlCache.queryBySql(ProcessStepEventQuery.getStartTimeWhitelistedPositionIds, params, new SingleColumnRowMapper<>(Long.class));

    return securityService.userHasPosition(currentUser.getHighestCompanyId(), whiteListedPositionIds, currentUser.getUserPositions());
  }

  public void deleteEventFromStep(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.trueUserId());
    sqlCache.updateBySql(ProcessStepEventQuery.deleteEventFromStep, params);
  }

  public Optional<ProcessStepEventAction> getStepEventAction(Long processStepEventActionId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", processStepEventActionId);
    return sqlCache.getBySql(ProcessStepEventQuery.getStepEventAction, params, new ProcessStepEventActionMapper<>(ProcessStepEventAction.class, om));
  }

  public Optional<ProcessStepEventAction> duplicateAction(Long processStepEventActionId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("actionId", processStepEventActionId);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    Long newActionId = sqlCache.queryForObjectBySql(ProcessStepEventQuery.duplicateAction, params, Long.class);
    return getStepEventAction(newActionId);
  }

  public Optional<ProcessStepEventAction> saveStepEventAction(Long processStepId, Long eventId, ProcessStepEventAction processStepEventAction) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyEventStatusTypeId", processStepEventAction.getCompanyEventStatusTypeId());
    params.put("companyProcessStepStatusTypeId", processStepEventAction.getCompanyProcessStepStatusTypeId());
    params.put("actionName", processStepEventAction.getActionName());
    params.put("actionTypeId", processStepEventAction.getActionTypeId());
    params.put("content", processStepEventAction.getContent());
    params.put("color", processStepEventAction.getColor());
    params.put("bgColor", processStepEventAction.getBgColor());
    params.put("requireStartTime", null != processStepEventAction.getRequireStartTime() ? processStepEventAction.getRequireStartTime() : false); // we have changed to ALWAYS require start time
    params.put("requireEndTime", null != processStepEventAction.getRequireEndTime() ? processStepEventAction.getRequireEndTime() : false);
    params.put("requireResource", null != processStepEventAction.getRequireResource() ? processStepEventAction.getRequireResource() : false);
    params.put("alwaysEnabled", null != processStepEventAction.getAlwaysEnabled() ? processStepEventAction.getAlwaysEnabled() : false);
    params.put("multipleUses", null != processStepEventAction.getMultipleUses() ? processStepEventAction.getMultipleUses() : false);
    params.put("hideFromWeb", null != processStepEventAction.getHideFromWeb() ? processStepEventAction.getHideFromWeb() : false);
    params.put("hideFromMobile", null != processStepEventAction.getHideFromMobile() ? processStepEventAction.getHideFromMobile() : false);
    params.put("userId", currentUser.trueUserId());
    params.put("processStepEventId", eventId);

    Long id;

    if (null != processStepEventAction.getId()) {
      id = processStepEventAction.getId();
      params.put("id", id);
      sqlCache.updateBySql(ProcessStepEventQuery.updateStepEventAction, params);

      if (null != processStepEventAction.getLogicListChanged() && processStepEventAction.getLogicListChanged()) {
        // archive all old logic before saving new logic
        sqlCache.updateBySql(ProcessStepEventQuery.archiveOldLogic, params);

        if (!processStepEventAction.getProcessStepEventLogicList().isEmpty()) {
          // handle saving logic items.
          // insert the new ones
          int count = 0;
          for (ProcessStepEventLogic logic : processStepEventAction.getProcessStepEventLogicList()) {
            if (null != logic.getProcessStepEventRequirementId() && (null == logic.getProcessStepRequirementImmutable() || !logic.getProcessStepRequirementImmutable())) {
              // update psr.immutable, if it is not already true. (don't have to do this for updates
              // because it should already be true by now)
              HashMap<String, Object> psrParams = new HashMap<>();
              psrParams.put("id", logic.getProcessStepEventRequirementId());
              sqlCache.updateBySql(ProcessStepEventRequirementQuery.setImmutable, psrParams);
            }

            HashMap<String, Object> logicParams = new HashMap<>();
            logicParams.put("id", processStepEventAction.getId());
            logicParams.put("processStepEventRequirementId", logic.getProcessStepEventRequirementId());
            logicParams.put("operationTypeId", logic.getOperationTypeId());
            logicParams.put("sqlOrder", count);
            logicParams.put("createdById", currentUser.trueUserId());
            sqlCache.updateBySql(ProcessStepEventQuery.insertLogic, logicParams);
            count++;
          }
        }
      }
    } else {
      id = sqlCache.updateBySqlReturningId(ProcessStepEventQuery.addStepEventAction, params, "id").longValue();
    }

    return getStepEventAction(id);
  }

  public String getActionLogicString(Long actionId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("actionId", actionId);
    Optional<String> logicString = sqlCache.queryForObjectOptionalBySql(ProcessStepEventQuery.actionLogicString, params, String.class);
    return logicString.orElse("");
  }

  public void updateEventActionOrder(List<ProcessStepEventAction> actions) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    for (ProcessStepEventAction action : actions) {
      params.put("displayOrder", action.getDisplayOrder());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("id", action.getId());
      // save each display_order
      sqlCache.updateBySql(ProcessStepEventQuery.updateActionDisplayOrder, params);
    }
  }

  public void deleteActionFromEvent(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.trueUserId());
    sqlCache.updateBySql(ProcessStepEventQuery.deleteActionFromEvent, params);
  }

  // CHILD LINKS
  public ProcessStepEventActionLink addLinkToAction(Long actionId, ProcessStepEventActionLink child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("linkId", child.getLinkId());
    params.put("processStepEventActionId", actionId);
    params.put("createdById", currentUser.trueUserId());

    Long id =
      sqlCache.updateBySqlReturningId(ProcessStepEventQuery.addLinkToAction, params, "id").longValue();
    return getActionChildLink(id);
  }

  public ProcessStepEventActionLink getActionChildLink(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
      .getBySql(ProcessStepEventQuery.getActionChildLink, params, ProcessStepEventActionLink.class)
      .orElse(null);
  }

  public void deleteLinkFromAction(Long childLinkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", childLinkId);
    sqlCache.updateBySql(ProcessStepEventQuery.deleteLinkFromAction, params);
  }

  //functions
  public ProcessStepEventActionChildFunction addChildFunctionToAction(Long actionId, ProcessStepEventActionChildFunction child) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyFunctionId", child.getCompanyFunctionId());
    params.put("processStepEventActionId", actionId);
    params.put("displayOrder", child.getDisplayOrder());
    params.put("createdById", currentUser.trueUserId());

    Long id = sqlCache.updateBySqlReturningId(ProcessStepEventQuery.addChildFunctionToAction, params, "id").longValue();

    processStepActionService.handleDynamicValueParams(child.getActionParamDynamicValues(), null, id);

    return getActionChildFunction(id);
  }

  public void deleteChildFunctionFromAction(Long childProcessId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", childProcessId);
    sqlCache.updateBySql(ProcessStepEventQuery.deleteActionChildFunction, params);
  }

  public void updateActionChildFunction(Long actionId, ProcessStepActionChildFunction child) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", child.getId());
    params.put("displayOrder", child.getDisplayOrder());
    sqlCache.updateBySql(ProcessStepEventQuery.updateActionChildFunction, params);

    processStepActionService.handleDynamicValueParams(child.getActionParamDynamicValues(), null, child.getId());
  }

  public List<ProcessStepEventActionChildFunction> getChildFunctionsWithParamValues(Long actionId, Long ppsEventId) {
    Map<String, Object> params = Map.of("id", actionId, "ppsEventId", ppsEventId);
    return sqlCache.queryBySql(ProcessStepEventQuery.getChildFunctionsByPpsEventId, params, new ProcessStepEventActionChildFunctionMapper<>(ProcessStepEventActionChildFunction.class, om));
  }

  public ProcessStepEventActionChildFunction getActionChildFunction(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProcessStepEventActionChildFunction> result = sqlCache.getBySql(ProcessStepEventQuery.getActionChildFunction, params, new ProcessStepEventActionChildFunctionMapper<>(ProcessStepEventActionChildFunction.class, om));
    return result.orElse(null);
  }


  public Long updateRequiredFieldStatus(Long actionId, ProcessStepEventActionField processStepEventActionField) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("actionId", actionId);
    params.put("userId", currentUser.trueUserId());
    params.put("pseafId", processStepEventActionField.getId());
    params.put("cfgaId", processStepEventActionField.getCustomFieldGroupAssignmentId());
    params.put("required", processStepEventActionField.getRequired());

    // required = row in pseaf AND required = true
    // optional = row in pseaf AND required = false
    // neither  = no row in pseaf

    Long id = null;
    // if there is already a record then update it IF required or optional is true
    if (null != processStepEventActionField.getId() && (processStepEventActionField.getOptional() || processStepEventActionField.getRequired())) {
      id = processStepEventActionField.getId();
      sqlCache.updateBySql(ProcessStepEventQuery.updateRequiredFieldStatus, params);
    } else if (null != processStepEventActionField.getId() && !processStepEventActionField.getRequired() && !processStepEventActionField.getOptional()) {
      // if there is already a record and not optional or required, then archive it
      sqlCache.updateBySql(ProcessStepEventQuery.archiveRequiredFieldStatus, params);
    } else {
      // otherwise add a new row
      id = sqlCache.updateBySqlReturningId(ProcessStepEventQuery.addRequiredFieldStatus, params, "id").longValue();
    }

    return id;
  }

  public static class ProcessStepEventMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepEventMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CompanyEventStatusType>> companyEventStatusTypeRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "companyEventStatusTypes", new JsonCollectionDeserializer(companyEventStatusTypeRef, objectMapper));

      TypeReference<List<ProcessStepEventAction>> processStepEventActionRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "processStepEventActions", new JsonCollectionDeserializer(processStepEventActionRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> processStepEventReadonlyRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "readonlyWhiteListPositions", new JsonCollectionDeserializer(processStepEventReadonlyRef, objectMapper));

      TypeReference<List<ProcessStepEventWorkQueueType>> processStepEventWqtRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "workQueueTypes", new JsonCollectionDeserializer(processStepEventWqtRef, objectMapper));
    }
  }

  public static class ProcessStepEventActionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepEventActionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ProcessStepEventLogic>> processStepEventLogicTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "processStepEventLogicList", new JsonCollectionDeserializer(processStepEventLogicTypeRef, objectMapper));

      TypeReference<List<ProcessStepEventActionLink>> childLinksRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "childLinks", new JsonCollectionDeserializer(childLinksRef, objectMapper));

      TypeReference<List<ProcessStepEventActionField>> customFieldsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "customFields", new JsonCollectionDeserializer(customFieldsRef, objectMapper));
    }
  }

  public static class ProcessStepEventActionChildFunctionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepEventActionChildFunctionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ActionParamDynamicValue>> actionParamDynamicValuesRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "actionParamDynamicValues", new JsonCollectionDeserializer(actionParamDynamicValuesRef, objectMapper));

      TypeReference<List<CompanyFunctionParam>> companyFunctionParamsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "companyFunctionParams", new JsonCollectionDeserializer<>(companyFunctionParamsRef, objectMapper));
    }
  }
}
