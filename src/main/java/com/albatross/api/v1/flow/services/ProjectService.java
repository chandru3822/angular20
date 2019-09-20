package com.albatross.api.v1.flow.services;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.google.common.collect.ImmutableMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final ProcessStepActionService processStepActionService;

  private final ProjectProcessStepRequirementService projectProcessStepRequirementService;

  public List<Project> getProjectsForProcess(Long processId) {
    User user = securityService.getCurrentUser();
    return sqlCache.query("project.getAllForCompanyProcess", ImmutableMap.of("companyId", user.getCompanyId() , "processId", processId), Project.class);
  }

  public Optional<Project> getProject(Long projectId) {
    return sqlCache.get("project.get", ImmutableMap.of("projectId", projectId), Project.class);
  }

  public List<Project> getProjectsForCustomer(Long customerId) {
    User user = securityService.getCurrentUser();
    return sqlCache.query("project.getAllForCustomer", ImmutableMap.of("companyId", user.getCompanyId(), "customerId", customerId), Project.class);
  }

  public List<ProjectProcessStep> getProcessStepsByProjectId(Long projectId) {
    return sqlCache.query("project.getProcessStepsByProjectId", ImmutableMap.of("projectId", projectId), ProjectProcessStep.class);
  }

  public ProjectProcessStep getProjectProcessStep(Long stepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stepId", stepId);
    ProjectProcessStep step = sqlCache.get("project.getProjectProcessStep", params, ProjectProcessStep.class).orElse(null);

    if (step != null) {
      step.setActions(processStepActionService.getActionsForStep(step.getProcessStepId()));
    }

    return step;
  }

  public boolean canCompleteAction(Long actionId, Long projectProcessStepId) {
    ProcessStepAction action = processStepActionService.getActionById(actionId);

    List<Long> requirementIds = action.getProcessStepLogicList().stream().filter(l -> l.getProcessStepRequirementId() != null).map(ProcessStepLogic::getProcessStepRequirementId).collect(Collectors.toList());
    List<ProjectProcessStepRequirement> requirements = projectProcessStepRequirementService.getByIds(requirementIds);


    // Check to if individual requirements are fulfilled and create a map of true/false with the requirementIds
    requirements.forEach(r -> r.setFulfilled(this.isRequirementMet(r)));

    StringBuilder logicString = new StringBuilder();

    // This should now just be creating logic by making a string of all the requirements in order and replacing requirementIds with their respective true/false value
    for (ProcessStepLogic logicStep: action.getProcessStepLogicList()) {
      if (logicStep.getOperationCode() != null) {
          logicString.append(" ").append(logicStep.getOperationCode()).append(" ");
      } else if (logicStep.getProcessStepRequirementId() != null) {
        Optional<ProjectProcessStepRequirement> requirement = requirements.stream().filter(r -> r.getId().equals(logicStep.getProcessStepRequirementId())).findFirst();
        requirement.ifPresent(r -> logicString.append(r.getFulfilled().toString()));
      }
    }

    ExpressionParser parser = new SpelExpressionParser();
    return parser.parseExpression(logicString.toString()).getValue(Boolean.class);
  }

  private boolean isRequirementMet(ProcessStepRequirement requirement) {
    if (requirement.getProcessStepRequirementTypeId() == 1) {
//      go through requirement.data_type_id to select the correct value prop. Then use the operation type to dun the correct comparison
    }
    return true;
  }
}
