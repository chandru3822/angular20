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

import java.util.Collections;
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
public class ProcessStepRequirementService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<ProcessStepRequirement> getRequirementsForStep(Long companyId, Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("processStepId", processStepId);
    List<ProcessStepRequirement> results = sqlCache.query("processStepRequirement.getRequirementsForStep", params, new ProcessStepRequirementMapper<>(ProcessStepRequirement.class, om));
    return results;
  }

  public void deleteRequirement(Long requirementId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", currentUser.getId());
    params.put("requirementId", requirementId);
    sqlCache.update("processStepRequirement.deleteRequirement", params);
  }

  public List<ProcessStepRequirementType> getRequirementTypes() {
    List<ProcessStepRequirementType> results = sqlCache.query("processStepRequirement.getRequirementTypes", Collections.emptyMap(), ProcessStepRequirementType.class);
    return results;
  }

  public ProcessStepRequirement getRequirementById(Long id) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProcessStepRequirement> result = sqlCache.get("processStepRequirement.getRequirement", params, new ProcessStepRequirementMapper<>(ProcessStepRequirement.class, om));

    return result.orElse(null);
  }

  public ProcessStepRequirement updateRequirement(ProcessStepRequirement requirement) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("operatorTypeId", requirement.getOperatorTypeId());
    params.put("requirementValue", requirement.getRequirementValue());
    params.put("modifiedById", currentUser.getId());
    params.put("id", requirement.getId());

    handleDefaultValueParams(requirement.getRequirementParamDefaultValues(), requirement.getId());

    Long id = sqlCache.updateReturningId("processStepRequirement.updateRequirement", params, "id").longValue();
    return getRequirementById(id);
  }

  public ProcessStepRequirement insertRequirement(Long companyId, ProcessStepRequirement requirement) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", requirement.getProcessStepRequirementTypeId());
    params.put("requirementTypeId", requirement.getProcessStepRequirementTypeId());
    params.put("operatorTypeId", requirement.getOperatorTypeId());
    params.put("requirementValue", requirement.getRequirementValue());
    params.put("customFieldGroupId", requirement.getCustomFieldGroupId());
    params.put("companyFunctionId", requirement.getCompanyFunctionId());
    params.put("requirementNbr", requirement.getRequirementNbr());
    params.put("createdById", currentUser.getId());
    params.put("processStepId", requirement.getProcessStepId());

    Long id = sqlCache.updateReturningId("processStepRequirement.insertRequirement", params, "id").longValue();

    handleDefaultValueParams(requirement.getRequirementParamDefaultValues(), id);

    return getRequirementById(id);
  }

  public void handleDefaultValueParams(List<RequirementParamDefaultValue> params, Long processStepRequirementId) {
    if(!params.isEmpty()) {
      User currentUser = securityService.getCurrentUser();

      for(RequirementParamDefaultValue p : params){
        HashMap<String, Object> defaultParams = new HashMap<>();
        defaultParams.put("dbFunctionParamId", p.getDbFunctionParamId());
        defaultParams.put("processStepRequirementId", processStepRequirementId);
        defaultParams.put("defaultValue", p.getDefaultValue());

        if(null != p.getId()){
          defaultParams.put("id", p.getId());
          defaultParams.put("modifiedById", currentUser.getId());
          sqlCache.update("processStepRequirement.updateRequirementParamDefaultValue", defaultParams);
        }else {
          defaultParams.put("createdById", currentUser.getId());
          sqlCache.update("processStepRequirement.insertRequirementParamDefaultValue", defaultParams);
        }
      }
    }
  }

  public static class ProcessStepRequirementMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepRequirementMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<RequirementParamDefaultValue>> requirementParamDefaultValuesRef = new TypeReference<List<RequirementParamDefaultValue>>() {};

      bw.registerCustomEditor(List.class, "requirementParamDefaultValues",
          new JsonCollectionDeserializer(requirementParamDefaultValuesRef, objectMapper));

    }
  }

}
