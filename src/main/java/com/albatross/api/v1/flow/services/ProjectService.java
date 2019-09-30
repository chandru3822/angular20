package com.albatross.api.v1.flow.services;

import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
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
import org.springframework.util.Assert;

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

  // It's assumed for date data types that it's always a data_type_requirement and never a literal comparison of values
  private boolean isRequirementMet(ProjectProcessStepRequirement r) {

    boolean requirementMet = false;

    if (r.getProcessStepRequirementTypeId() == 1) {
//      go through requirement.data_type_id to select the correct value prop. Then use the operation type to dun the correct comparison
        if (r.getDataTypeId() == 1) {
          requirementMet = calculateDateRequirement(r);
        }
    }
    return requirementMet;
  }


  private boolean calculateDateRequirement(ProjectProcessStepRequirement r) {

    LocalDateTime fieldValue = (r.getDateValue() !=  null) ? r.getDateValue().toLocalDateTime() : null;
    LocalDateTime now = LocalDateTime.now();
    String secondaryValue = (r.isSecondaryRequirement()) ? r.getSecondaryRequirementValue() : null;

    boolean passed = false;

    if (!r.isDataTypeRequirement()) {
      // do direct literal operator compare
      // try to make a date out of the requirement value
      try {
        LocalDateTime reqValue = LocalDateTime.parse(r.getRequirementValue());
        passed = compareDates(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (DateTimeParseException e) {
        log.error("Unable to parse requirement value date", e);
      }
    } else {

      // @TODO: Still need to decide how to handle stupid cases like the user inputting the field value is greater than null
      switch (r.getDataTypeRequirementId().intValue()) {
        case 1:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue, now.minusHours(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 2:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue, now.plusHours(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 3:
          passed = compareDates(fieldValue, now, r.getOperatorTypeId());
          break;
        case 4:
          try {
            Assert.isNull(fieldValue, "shibby flibby");
            passed = true;
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
        case 5:
          try {
            Assert.notNull(fieldValue, "flibby shibby");
            passed = true;
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
      }
    }

    return passed;
  }

  private boolean compareDates(LocalDateTime date, LocalDateTime compareDate, Long operatorTypeId) {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date.isEqual(compareDate);
        break;
      case 2:
        passed = !date.isEqual(compareDate);
        break;
      case 3:
        passed = date.isAfter(compareDate);
        break;
      case 4:
        passed = date.isBefore(compareDate);
        break;
    }

    return passed;
  }
}
