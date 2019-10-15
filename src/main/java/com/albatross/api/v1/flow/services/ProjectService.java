package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

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

  public Optional<Project> insertProject(Long customerId, Long processId) {
    //todo: switching gears to work with keller. will come back to this
    User user = securityService.getCurrentUser();

    Long id = sqlCache.updateReturningId("project.insert",
        ImmutableMap.of("customerId", customerId,
                        "createdById", user.getId(),
                        "projectName", "Why do we have this?",
                        "processId", processId), "id").longValue();

    return getProject(id);
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

  public ProjectProcessStep insertProjectProcessStep(Long projectId, Long processStepId, Long statusTypeId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("processStepId", processStepId);
    params.put("statusTypeId", statusTypeId);
    params.put("createdById", user.getId());
    ProjectProcessStep step = sqlCache.get("project.insertProjectProcessStep", params, ProjectProcessStep.class).orElse(null);

    if (step != null) {
      step.setActions(processStepActionService.getActionsForStep(step.getProcessStepId()));
    }

    return step;
  }

  public boolean canCompleteAction(Long actionId, Long projectProcessStepId) throws Exception {
    ProcessStepAction action = processStepActionService.getActionById(actionId);

    List<Long> requirementIds = action.getProcessStepLogicList().stream().filter(l -> l.getProcessStepRequirementId() != null).map(ProcessStepLogic::getProcessStepRequirementId).collect(Collectors.toList());
    List<ProjectProcessStepRequirement> requirements = projectProcessStepRequirementService.getByIds(requirementIds);


    // Check to if individual requirements are fulfilled and create a map of true/false with the requirementIds
    // @TODO: Unable to do this with a lambda like requirements.foreach(r ->... while being able to throw an exception ¯\_(ツ)_/¯
    for (ProjectProcessStepRequirement r: requirements) {
      try {
        r.setFulfilled(this.isRequirementMet(r));
      } catch (Exception e) {
        log.error(String.format("Exception while parsing date requirement value for process step requirement ID: %s", r.getId()));
        e.printStackTrace();
        throw e;
      }
    }

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
  private boolean isRequirementMet(ProjectProcessStepRequirement r) throws Exception {

    boolean requirementMet = false;

    if (r.getProcessStepRequirementTypeId() == 1) {
//      go through requirement.data_type_id to select the correct value prop. Then use the operation type to dun the correct comparison
        if (r.getDataTypeId() == 1) {
          requirementMet = calculateDateRequirement(r);
        }

        switch (r.getDataTypeId().intValue()) {
          case 1:
            requirementMet = calculateDateRequirement(r);
            break;
          case 2:
            requirementMet = calculateTimestampRequirement(r);
            break;
          case 3:
            requirementMet = calculateBooleanRequirement(r);
            break;
          case 4:
            requirementMet = calculateNumericRequirement(r);
            break;
          case 5:
            requirementMet = calculateTextRequirement(r);
            break;
          case 6:
            requirementMet = calculateIntRequirement(r);
          case 7:
            requirementMet = calculateIntArrayRequirement(r);
          default:
            //@TODO: blow up with error?
        }
    }
    return requirementMet;
  }

  private boolean calculateIntArrayRequirement(ProjectProcessStepRequirement r) throws Exception {

    List<Long> fieldValue = r.getIntArrayValue();

    boolean passed = false;

    return passed;
  }

  private boolean calculateIntRequirement(ProjectProcessStepRequirement r) throws Exception {

    Long fieldValue = r.getIntValue();
    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        Long reqValue = Long.parseLong(r.getRequirementValue());
        passed = compareInt(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (Exception e) {
        throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 20:
          passed = fieldValue == null;
          break;
        case 21:
          passed = fieldValue != null;
          break;
        default:
          throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
      }
    }

    return passed;
  }

  private boolean compareInt(Long number, Long compareNumber, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(number, compareNumber);
        break;
      case 2:
        passed = !Objects.equals(number, compareNumber);
        break;
      case 3:
        passed = (number != null && compareNumber != null) && number > compareNumber;
        break;
      case 4:
        passed = (number != null && compareNumber != null) && number < compareNumber;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateTextRequirement(ProjectProcessStepRequirement r) throws Exception {

    String fieldValue = r.getTextValue();

    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        String reqValue = r.getRequirementValue();
        passed = compareText(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (Exception e) {
        throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 18:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue == null;
              break;
            case 2:
              passed = fieldValue != null;
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
          }
          break;
        case 19:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue != null;
              break;
            case 2:
              passed = fieldValue == null;
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
          }
      }
    }
    return passed;
  }

  private boolean compareText(String text, String compareText, Long operatorTypeId) throws Exception {

    boolean passed = false;

    text = (text != null) ? text.trim().toLowerCase() : "";
    compareText = (compareText != null) ? compareText.trim().toLowerCase() : "";

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = text.equals(compareText);
        break;
      case 2:
        passed = !text.equals(compareText);
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateNumericRequirement(ProjectProcessStepRequirement r) throws Exception {

    Double fieldValue = (r.getNumericValue() == null) ? null : r.getNumericValue().setScale(2, RoundingMode.DOWN).doubleValue();

    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        Double reqValue = new BigDecimal(r.getRequirementValue()).setScale(2, RoundingMode.DOWN).doubleValue();
        passed = compareNumeric(fieldValue, reqValue, r.getOperatorTypeId());
      } catch(Exception e) {
        throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch(r.getDataTypeRequirementId().intValue()) {
        case 16:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = fieldValue == null;
                break;
              case 2:
                passed = fieldValue != null;
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
            }
          break;
        case 17:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue != null;
              break;
            case 2:
              passed = fieldValue == null;
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
          }
          break;
      }
    }

    return passed;
  }

  private boolean compareNumeric(Double number, Double compareNumber, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(number, compareNumber);
        break;
      case 2:
        passed = !Objects.equals(number, compareNumber);
        break;
      case 3:
        passed = (number != null && compareNumber != null) && number > compareNumber;
        break;
      case 4:
        passed = (number != null && compareNumber != null) && number < compareNumber;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateBooleanRequirement(ProjectProcessStepRequirement r) throws Exception {

    Boolean fieldValue = r.getBooleanValue();
    Boolean reqValue = Boolean.parseBoolean(r.getRequirementValue());

    boolean passed = false;

    switch (r.getOperatorTypeId().intValue()) {
      case 1:
        passed = fieldValue == reqValue;
        break;
      case 2:
        passed = fieldValue != reqValue;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Boolean with operator of ID: %s", r.getOperatorTypeId()));
    }

    return passed;
  }

  private boolean calculateTimestampRequirement(ProjectProcessStepRequirement r) throws Exception {

    LocalDateTime fieldValue = (r.getTimestampValue() != null) ? r.getTimestampValue().toLocalDateTime().withMinute(0).withSecond(0).withNano(0) : null;
    LocalDateTime now = LocalDateTime.now().withMinute(0).withSecond(0).withNano(0);
    String secondaryValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

    boolean passed = false;

    if (null == r.getDataTypeRequirementId()) {
      try {
        LocalDateTime reqValue = LocalDateTime.parse(r.getRequirementValue());
        passed = compareDateTimes(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (DateTimeParseException e) {
        throw new Exception(String.format("Unable to parse Timestamp type requirement value of: %s", r.getRequirementValue()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 6:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue.toLocalDate(), now.minusDays(Long.parseLong(secondaryValue)).toLocalDate(), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 7:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue.toLocalDate(), now.plusDays(Long.parseLong(secondaryValue)).toLocalDate(), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 8:
          passed = compareDates(fieldValue.toLocalDate(), now.toLocalDate(), r.getOperatorTypeId());
          break;
        case 9:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDateTimes(fieldValue, now.minusHours(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 10:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDateTimes(fieldValue, now.plusHours(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 11:
          passed = compareDateTimes(fieldValue, now, r.getOperatorTypeId());
          break;
        case 12:
          try {
            Assert.isNull(fieldValue, "null check failed");
            passed = true;
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
        case 13:
          try {
            Assert.notNull(fieldValue, "not-null check failed");
            passed = true;
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
      }
    }

    return passed;
  }

  private boolean compareDateTimes(LocalDateTime date, LocalDateTime compareDate, Long operatorTypeId) throws Exception {

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
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateDateRequirement(ProjectProcessStepRequirement r) throws Exception {

    LocalDate fieldValue = (r.getDateValue() !=  null) ? r.getDateValue().toLocalDateTime().toLocalDate() : null;
    LocalDate now = LocalDate.now();
    String secondaryValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

    boolean passed = false;

    if (null == r.getDataTypeRequirementId()) {
      // do direct literal operator compare
      // try to make a date out of the requirement value
      try {
        LocalDate reqValue = LocalDate.parse(r.getRequirementValue());
        passed = compareDates(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (DateTimeParseException e) {
        throw new Exception(String.format("Unable to parse Date type requirement value of: %s", r.getRequirementValue()));
      }
    } else {
      // @TODO: Still need to decide how to handle stupid cases like the user inputting the field value is greater than null
      switch (r.getDataTypeRequirementId().intValue()) {
        case 1:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue, now.minusDays(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 2:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue, now.plusDays(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something?
          }
          break;
        case 3:
          passed = compareDates(fieldValue, now, r.getOperatorTypeId());
          break;
        case 4:
          try {
            Assert.isNull(fieldValue, "null check failed");
            passed = true;
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
        case 5:
          try {
            Assert.notNull(fieldValue, "not-null check failed");
            passed = true;
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
      }
    }

    return passed;
  }

  private boolean compareDates(LocalDate date, LocalDate compareDate, Long operatorTypeId) throws Exception {

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
      default:
        throw new Exception(String.format("Unable to parse data type of Date with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }
}
