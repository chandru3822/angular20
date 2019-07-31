package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProcessStepRequirement;
import com.albatross.api.v1.flow.model.ProcessStepRequirementType;
import com.albatross.api.v1.flow.model.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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

  public List<ProcessStepRequirement> getRequirementsForStep(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    //todo: fix this query to exclude archived and get by processStepId
    //todo: and do union with requirements coming from functions
    List<ProcessStepRequirement> results = sqlCache.query("processStepRequirement.getRequirementsForStep", Collections.emptyMap(), ProcessStepRequirement.class);
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

    Optional<ProcessStepRequirement> result = sqlCache.get("processStepRequirement.getRequirement", params, ProcessStepRequirement.class);

    return result.orElse(null);
  }

  public ProcessStepRequirement insertRequirement(ProcessStepRequirement requirement) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("requirementTypeId", requirement.getProcessStepRequirementTypeId());
    params.put("operatorTypeId", requirement.getOperatorTypeId());
    params.put("requirementValue", requirement.getProcessRequirementValue());
    params.put("customFieldGroupId", requirement.getCustomFieldGroupId());
    params.put("companyFunctionId", requirement.getCompanyFunctionId());
    params.put("requirementNbr", requirement.getRequirementNbr());
    params.put("createdById", currentUser.getId());

    Long id = sqlCache.updateReturningId("processStepRequirement.insertRequirement", params, "id").longValue();
    return getRequirementById(id);
  }

}
