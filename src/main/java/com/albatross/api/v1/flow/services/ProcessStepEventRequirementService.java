package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.event.EventRequirementParamDynamicValue;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAction;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventRequirement;
import com.albatross.api.v1.flow.queries.ProcessStepEventRequirementQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProcessStepEventRequirementService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<ProcessStepEventRequirement> getRequirementsForEvent(Long processStepId, Long processStepEventId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("processStepEventId", processStepEventId);
    params.put("processStepId", processStepId);
    List<ProcessStepEventRequirement> results = sqlCache.queryBySql(ProcessStepEventRequirementQuery.getRequirementsForEvent, params, new ProcessStepEventRequirementMapper<>(ProcessStepEventRequirement.class, om));

    // todo: this is duplicated from custom field value service but didn't quite match up, probably
    // could re-write to combine the two
    for (ProcessStepEventRequirement psr : results) {
      if (null != psr.getCustomFieldSqlKey()) {
        String sql = sqlCache.getByKey(psr.getCustomFieldSqlKey());
        if (null != sql) {
          HashMap<String, Object> params2 = new HashMap<>();
          params2.put("projectId", null);
          params2.put("userId", user.getId());
          List<ListOfValue> listOfValues = sqlCache.queryBySql(sql, params2, ListOfValue.class);
          psr.setAvailableListOfValues(listOfValues);
        }
      }
    }

    return results;
  }

  public List<ProcessStepAction> deleteRequirement(Long requirementId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.trueUserId());
    params.put("requirementId", requirementId);
    //    List<ProcessStepAction> actionsUsingRequirement = new ArrayList<>();
    List<ProcessStepAction> actionsUsingRequirement = sqlCache.queryBySql(ProcessStepEventRequirementQuery.actionsUsingRequirement, params, ProcessStepAction.class);

    if (!actionsUsingRequirement.isEmpty()) {
      return actionsUsingRequirement;
    } else {
      sqlCache.updateBySql(ProcessStepEventRequirementQuery.deleteRequirement, params);
      return null;
    }
  }

  public ProcessStepEventRequirement getRequirementById(Long id) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(ProcessStepEventRequirementQuery.getRequirement, params, new ProcessStepEventRequirementMapper<>(ProcessStepEventRequirement.class, om)).orElse(null);
  }

  public ProcessStepEventRequirement updateRequirement(ProcessStepEventRequirement requirement) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("operatorTypeId", requirement.getOperatorTypeId());
    params.put("requirementValue", requirement.getRequirementValue());
    params.put("secondaryRequirementValue", requirement.getSecondaryRequirementValue());
    params.put("dataTypeRequirementId", requirement.getDataTypeRequirementId());
    params.put("failIfNoReferenceStepFound", null != requirement.getFailIfNoReferenceStepFound() ? requirement.getFailIfNoReferenceStepFound() : false);
    params.put("listOfValueId", requirement.getListOfValueId());
    params.put("systemListOptionId", requirement.getSystemListOptionId());
    params.put("customSqlOptionId", requirement.getCustomSqlOptionId());
    params.put("listOfValueIds", (requirement.getListOfValueIds() == null) ? List.of() : requirement.getListOfValueIds());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", requirement.getId());

    handleDynamicValueParams(requirement.getRequirementParamDynamicValues(), requirement.getId());

    Long id = sqlCache.updateBySqlReturningId(ProcessStepEventRequirementQuery.updateRequirement, params, "id").longValue();
    return getRequirementById(id);
  }

  public ProcessStepEventRequirement insertRequirement(ProcessStepEventRequirement requirement) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("requirementTypeId", requirement.getProcessStepRequirementTypeId());
    params.put("processStepEventId", requirement.getProcessStepEventId());
    params.put("referenceProcessStepId", requirement.getReferenceProcessStepId());
    params.put("failIfNoReferenceStepFound", null != requirement.getFailIfNoReferenceStepFound() ? requirement.getFailIfNoReferenceStepFound() : false);
    params.put("operatorTypeId", requirement.getOperatorTypeId());
    params.put("requirementValue", requirement.getRequirementValue());
    params.put("secondaryRequirementValue", requirement.getSecondaryRequirementValue());
    params.put("dataTypeRequirementId", requirement.getDataTypeRequirementId());
    params.put("listOfValueId", requirement.getListOfValueId());
    params.put("listOfValueIds", (requirement.getListOfValueIds() == null) ? List.of() : requirement.getListOfValueIds());
    params.put("customFieldGroupAssignmentId", requirement.getCustomFieldGroupAssignmentId());
    params.put("companyFunctionId", requirement.getCompanyFunctionId());
    params.put("requirementNbr", requirement.getRequirementNbr());
    params.put("createdById", currentUser.trueUserId());
    params.put("processStepId", requirement.getProcessStepId());
    params.put("systemListOptionId", requirement.getSystemListOptionId());
    params.put("customSqlOptionId", requirement.getCustomSqlOptionId());

    Long id = sqlCache.updateBySqlReturningId(ProcessStepEventRequirementQuery.insertRequirement, params, "id").longValue();

    handleDynamicValueParams(requirement.getRequirementParamDynamicValues(), id);

    return getRequirementById(id);
  }

  public void handleDynamicValueParams(List<EventRequirementParamDynamicValue> dynamicValues, Long processStepEventRequirementId) {
    if (!dynamicValues.isEmpty()) {
      User currentUser = securityService.getCurrentUser();

      for (EventRequirementParamDynamicValue p : dynamicValues) {
        HashMap<String, Object> dynamicParams = new HashMap<>();
        dynamicParams.put("dbFunctionParamId", p.getDbFunctionParamId());
        dynamicParams.put("processStepEventRequirementId", processStepEventRequirementId);
        dynamicParams.put("dynamicValue", p.getDynamicValue());

        if (null != p.getId()) {
          dynamicParams.put("id", p.getId());
          dynamicParams.put("modifiedById", currentUser.trueUserId());
          sqlCache.updateBySql(ProcessStepEventRequirementQuery.updateRequirementParamDynamicValue, dynamicParams);
        } else {
          dynamicParams.put("createdById", currentUser.trueUserId());
          sqlCache.updateBySql(ProcessStepEventRequirementQuery.insertRequirementParamDynamicValue, dynamicParams);
        }
      }
    }
  }

  public static class ProcessStepEventRequirementMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepEventRequirementMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<EventRequirementParamDynamicValue>> requirementParamDynamicValuesRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "requirementParamDynamicValues", new JsonCollectionDeserializer(requirementParamDynamicValuesRef, objectMapper));

      TypeReference<DataTypeRequirement> dataTypeRequirementRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(Object.class, "dataTypeRequirement", new JsonCollectionDeserializer(dataTypeRequirementRef, objectMapper));

      TypeReference<CustomField> customFieldRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(Object.class, "customField", new JsonCollectionDeserializer(customFieldRef, objectMapper));

      TypeReference<ListOfValue> listOfValueRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(Object.class, "listOfValue", new JsonCollectionDeserializer(listOfValueRef, objectMapper));

      TypeReference<List<ListOfValue>> listOfValuesRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "listOfValues", new JsonCollectionDeserializer(listOfValuesRef, objectMapper));

      TypeReference<List<ListOfValue>> availableListOfValuesRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "availableListOfValues", new JsonCollectionDeserializer(availableListOfValuesRef, objectMapper));

      TypeReference<List<Integer>> listOfValueIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "listOfValueIds", new JsonCollectionDeserializer(listOfValueIdsRef, objectMapper));

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "systemListOptionIds", new JsonCollectionDeserializer(systemListOptionIdsRef, objectMapper));
    }
  }
}
