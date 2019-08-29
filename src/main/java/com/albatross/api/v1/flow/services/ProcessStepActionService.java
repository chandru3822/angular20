package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProcessStepAction;
import com.albatross.api.v1.flow.model.ProcessStepLogic;
import com.albatross.api.v1.flow.model.User;
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

    Optional<ProcessStepAction> result = sqlCache.get("processStepAction.getAction", params, ProcessStepAction.class);

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
    }
  }

}
