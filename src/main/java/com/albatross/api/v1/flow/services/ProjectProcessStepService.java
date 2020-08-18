package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.PutObjectResult;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.Assert;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;


//@TODO: Had to make private functions public in this class to be able to unit test due to this issue. https://github.com/powermock/powermock/issues/929
// I don't like it and would rather have them be private. Change back if/when possible

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectProcessStepService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final AttachmentService attachmentService;

  private final ProcessStepStatusService processStepStatusService;

  private final AmazonS3 s3;

  private final ProcessStepActionService processStepActionService;

  private final ProjectProcessStepRequirementService projectProcessStepRequirementService;

  private final AsyncProjectProcessStepService asyncProjectProcessStepService;

  private final CustomFieldValueService customFieldValueService;

  private final ObjectMapper om;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public List<Attachment> getProjectProcessStepAttachments(Long projectProcessStepId, Boolean isMobile) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    List<Attachment> attachments = sqlCache.query("projectProcessStep.getProjectProcessStepAttachments", params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped code right now and I hate it
  public Attachment addAttachment(MultipartFile file, Long projectProcessStepId, Long attachmentTypeId) throws IOException {
    User user = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    //get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key = String.format( user.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    metadata.setContentType(file.getContentType());
    metadata.setCacheControl("public, max-age=31536000");

    PutObjectRequest objectRequest = new PutObjectRequest(storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

    PutObjectResult result = s3.putObject(objectRequest
      .withCannedAcl(CannedAccessControlList.PublicRead));

    String url = s3.getUrl(user.getAwsBucket(), key).toExternalForm();

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", file.getOriginalFilename());
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("createdById", user.getId());
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("companyId", user.getCompanyId());

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

    params.clear();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", user.getId());

    sqlCache.update("projectProcessStep.addAttachment", params);

    return attachmentService.findById(storageBucket, attachmentId);
  }

  @Transactional
  public void setStatus(Long projectProcessStepId, Long processStepStatusTypeId, Long companyProcessStepStatusTypeId) {
    User user = securityService.getCurrentUser();
    ProjectProcessStep currentStep = this.getProjectProcessStep(projectProcessStepId);

    if (currentStep == null) {
        throw new RuntimeException("The given process step does not exist");
    }

    if (currentStep.getProcessStepStatusTypeId().equals(processStepStatusTypeId)) {
        return;
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("processStepStatusTypeId", processStepStatusTypeId);
    params.put("companyProcessStepStatusTypeId", companyProcessStepStatusTypeId);
    params.put("userId", user.getId());
    params.put("projectId", currentStep.getProjectId());
    params.put("processStepId", currentStep.getProcessStepId());
    params.put("main", currentStep.getMain());

    // If setting status to active, verify no other steps on this project are active
    if (processStepStatusTypeId == 1) {
        Long activeIdCount = sqlCache.queryForObject("projectProcessStep.getActiveCountInProject", params, Long.class);
        if (activeIdCount > 0) {
            throw new RuntimeException("Can have only 1 active process step of this type");
        }

        sqlCache.update("projectProcessStep.clearMain", params);

        // Active PPS are primary by default
        params.put("main", true);
    }

    sqlCache.update("projectProcessStep.setStatus", params);
  }

  public ResponseEntity updateOwner(Long projectProcessStepId, Owner owner, Boolean blockOverride) {
    /* blockOverride = don't allow someone to assign to themselves if it is already assigned to someone else.
     / (race-condition should be the only time this is really used)
     / or if someone sits on the ui for a long time before clicking "Assign to me"
    */
    HashMap<String, Object> params = new HashMap<>();
    params.put("userPositionId", (owner == null) ? null : owner.getUserPositionId());
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("userId", securityService.getCurrentUser().getId());


    boolean canSave = false;
    if(null != blockOverride && blockOverride) {
      //check for existing owner
      Long id = sqlCache.queryForObject("projectProcessStep.getOwner", params, Long.class);
      canSave = id == null;
    }

    if(null == blockOverride || !blockOverride || canSave) {
      sqlCache.update("projectProcessStep.updateOwner", params);
      return ResponseEntity.ok("Owner Saved");
    } else {
      return ResponseEntity.badRequest().body("Project Process Step is already assigned to another user. Please refresh page.");
    }

  }

  public ProjectProcessStep getProjectProcessStep(Long stepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stepId", stepId);
    ProjectProcessStep step = sqlCache.get("projectProcessStep.getProjectProcessStep", params, new ProjectProcessStepMapper<>(ProjectProcessStep.class, om)).orElse(null);

    if (step != null) {
      step.setActions(processStepActionService.getActionsForStep(step.getProcessStepId()));
    }

    return step;
  }

  @Transactional
  public ProjectProcessStep insertProjectProcessStep(Long projectId, Long processStepId, Long userPositionId, Boolean main) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("processStepId", processStepId);
    params.put("userPositionId", userPositionId);
    params.put("userId", user.getId());
    params.put("main", main);
    params.put("companyId", user.getCompanyId());

    if (main) {
        sqlCache.update("projectProcessStep.clearMain", params);
    }

    // New project process steps are defaulted to active. Cancel any existing active steps so there is only 1
    sqlCache.update("projectProcessStep.cancelActive", params);

    Long id = sqlCache.updateReturningId("projectProcessStep.insertProjectProcessStep", params, "id").longValue();

    return getProjectProcessStep(id);
  }

//  public List<CustomFieldGroup> saveProjectProcessStep(ProjectProcessStep pps) {
//    User currentUser = securityService.getCurrentUser();
//
//    //todo: handle the rest of the save ... if any - see userService.saveUser
//
//    handleSavingCustomFieldValues(pps.getCustomFieldGroups(), pps.getProjectProcessStepId());
//
//    return customFieldValueService.getProjectProcessStepCustomValues(pps.getProjectProcessStepId());
//  }
//
//  public void handleSavingCustomFieldValues(List<CustomFieldGroup> groups, Long primaryId){
//    User currentUser = securityService.getCurrentUser();
//    for(CustomFieldGroup group : groups) {
//      for(CustomFieldValue cfv : group.getCustomFieldValues()){
//        //todo: only save if something changed
//        if(fieldHasValue(cfv)) {
//          HashMap<String, Object> params = new HashMap<>();
//          params.put("dateValue", cfv.getDateValue());
//          params.put("timestampValue", cfv.getTimestampValue());
//          params.put("booleanValue", null != cfv.getBooleanValue() ? cfv.getBooleanValue() : false);
//          params.put("textValue", cfv.getTextValue());
//          params.put("numericValue", cfv.getNumericValue());
//          params.put("intValue", cfv.getIntValue());
//          params.put("intArrayValue", cfv.getIntArrayValue());
//          params.put("projectProcessStepId", primaryId);
//          params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
//
//          if(null != cfv.getId()){
//            params.put("id", cfv.getId());
//            params.put("modifiedById", currentUser.getId());
//            sqlCache.update("customFieldValues.updateProjectProcessStepCustomFieldValue", params);
//          } else {
//            params.put("createdById", currentUser.getId());
//            sqlCache.update("customFieldValues.insertProjectProcessStepCustomFieldValue", params);
//          }
//        }
//      }
//    }
//  }

//  public Boolean fieldHasValue (CustomFieldValue cv) {
//    return null != cv.getId() || null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
//      || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
//  }

  @Transactional
  public void deleteProjectProcessStep(Long projectProcessStepId) {
      ProjectProcessStep deletingStep = this.getProjectProcessStep(projectProcessStepId);

      if (deletingStep != null) {
          if (deletingStep.getMain()) {
            throw new RuntimeException("Can not delete a primary process step. Must designate another primary step first");
          }

          sqlCache.query("projectProcessStep.delete", Map.of("projectProcessStepId", projectProcessStepId), String.class);
      }
  }


    public void updateMain(Long projectProcessStepId) {
        ProjectProcessStep updatingStep = this.getProjectProcessStep(projectProcessStepId);

        if (updatingStep != null) {

            Map<String, Object> params = Map.of("projectProcessStepId", projectProcessStepId, "projectId", updatingStep.getProjectId(), "processStepId", updatingStep.getProcessStepId());

            Long activeIdCount = sqlCache.queryForObject("projectProcessStep.getActiveCountInProject", params, Long.class);

            if (activeIdCount > 0) {
                throw new RuntimeException("An active primary process step already exists");
            }

            sqlCache.update("projectProcessStep.updateMain", params);
        }
    }


    public static class ProjectProcessStepMapper<T> extends BeanPropertyRowMapper<T> {
    public final ObjectMapper objectMapper;


    public ProjectProcessStepMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Owner> ownerRef = new TypeReference<>() {};
      bw.registerCustomEditor(Object.class, "owner", new JsonCollectionDeserializer(ownerRef, objectMapper));
    }
  }

  public List<Owner> getOwners(Long processStepProcessId) {
    return sqlCache.query("projectProcessStep.getOwners", Map.of("processStepProcessId", processStepProcessId), Owner.class);
  }
  /************************************************************* ACTION LOGIC ********************************************************************************/

  @Transactional
  public void performAction(Long actionId, Long projectProcessStepId) {
    /*
     **High level pseudo logic:**

     * transaction all queries so current state is kept on any errors
     * Performance will be key here as it will be hit a lot and business logic will grow

     * gather required data
     * set the parent step to the specified status
     * set them to the active status
     * recursively check if child processes have children and auto-triggered until all auto-triggered child process steps have been created with active statuses
     */

    ProjectProcessStep projectProcessStep = this.getProjectProcessStep(projectProcessStepId);
    ProcessStepAction action = processStepActionService.getActionById(actionId);
    if (action.getCompanyProcessStepStatusTypeId() != null) {
      this.setStatus(projectProcessStepId, action.getProcessStepStatusTypeId(), action.getCompanyProcessStepStatusTypeId());
    }

    List<ProjectProcessStep> newSteps = new ArrayList<>();

    Long ownerUserPositionId = (projectProcessStep.getOwner() != null) ? projectProcessStep.getOwner().getUserPositionId() : null;

    action.getProcessStepActionChildProcesses().forEach(childStep -> {
      newSteps.add(this.insertProjectProcessStep(projectProcessStep.getProjectId(), childStep.getProcessStepId(), ownerUserPositionId, true));
    });

    //@TODO: @humes (or anybody ;-)) use newSteps to recursively check for auto-triggered process step actions on child process steps (recursive to perform auto-triggers for each generation of child process steps)

    asyncProjectProcessStepService.asyncRunChildFunctions(actionId, projectProcessStepId, securityService.getCurrentUser().getId());
  }

  public boolean canPerformAction(Long actionId, Long projectProcessStepId) throws Exception {

    ProcessStepAction action = processStepActionService.getActionById(actionId);

    if (action.getAlwaysEnabled()) {
      return true;
    }

    if (action.getProcessStepLogicList().isEmpty()) {
      return false;
    }

    List<Long> requirementIds = action.getProcessStepLogicList().stream()
      .filter(step -> step.getProcessStepRequirementId() != null)
      .map(ProcessStepLogic::getProcessStepRequirementId)
      .collect(Collectors.toList());

    List<ProjectProcessStepRequirement> requirements = projectProcessStepRequirementService.getByProjectProcessStepId(projectProcessStepId, requirementIds);

    // If there are not any requirements, then it can be completed
    if (requirements.isEmpty()) {
      return true;
    }

    // Check to if individual requirements are fulfilled
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
    if (logicString.length() > 0) {
      return parser.parseExpression(logicString.toString()).getValue(Boolean.class);
    } else {
      return requirements.stream().allMatch(ProcessStepRequirement::getFulfilled);
    }
  }

  // It's assumed for date data types that it's always a data_type_requirement and never a literal comparison of values
  public boolean isRequirementMet(ProjectProcessStepRequirement r) throws Exception {

    boolean requirementMet = false;

    if (r.getProcessStepRequirementTypeId() == 2) {
      String params = String.join(", ", prepareFunctionParams(r.getCompanyFunctionParams(), r.getProjectId()));
      String query = String.format("select * from %s(%s)", r.getFunctionName(), params);
      //@TODO: Account for function return data types 7 and 9 returning lists
      Optional<Object> returnValue = sqlCache.getBySql(query, null, new SingleColumnRowMapper<>(Object.class));
      //@TODO: compare returnValue to the requirement value
      requirementMet = calculateFunctionRequirement(returnValue.orElse(null), r);
    } else {
//      go through requirement.data_type_id to select the correct value prop. Then use the operation type to dun the correct comparison

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
              case 9:
                  requirementMet = ((r.getHasListValues() != null && r.getHasListValues()) || r.getCompanySystemListId() != null) ? caclulateDropdownRequirement(r) : calculateIntRequirement(r);
                  break;
              case 7:
                  requirementMet = calculateMultiselectRequirement(r);
                  break;
              case 8:
                  requirementMet = calculateCustomRequirement(r);
              default:
                  //@TODO: blow up with error?
          }
      }
    return requirementMet;
  }

  public boolean calculateCustomRequirement(ProjectProcessStepRequirement r) throws Exception {
      boolean passed = false;

      if (r.getCustomFieldSqlKey() != null) {
          // We can compare the IDs without actually having to get the values behind them. Sorta like C++ pointers
          // This also assumes data type ID of 8 (custom behavior fields) are lists. If we start supporting other types with custom behavior, this needs to update with it
          if (r.getDataTypeRequirementId() == null) {
              switch (r.getOperatorTypeId().intValue()) {
                  case 1:
                      passed = Objects.equals(r.getCustomSqlOptionId(), r.getIntValue());
                      break;
                  case 2:
                      passed = !Objects.equals(r.getCustomSqlOptionId(), r.getIntValue());
                      break;
                  case 3:
                  case 4:
                      break;
                  default:
                      throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
              }
          } else {
              switch (r.getDataTypeRequirementId().intValue()) {
                  case 24:
                      switch (r.getOperatorTypeId().intValue()) {
                          case 1:
                              passed = r.getIntValue() == null;
                              break;
                          case 2:
                              passed = r.getIntValue() != null;

                      }
                      break;
                  case 25:
                      switch (r.getOperatorTypeId().intValue()) {
                          case 1:
                              passed = r.getIntValue() != null;
                              break;
                          case 2:
                              passed = r.getIntValue() == null;
                      }
              }
          }
      }

      return passed;
  }

  public boolean calculateFunctionRequirement(Object functionResult, ProjectProcessStepRequirement r) throws Exception {
    boolean passed = false;
    switch (r.getDataTypeId().intValue()) {
      case 1:
        // @TODO: Duped from the button logic, potentially combine
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate dateFunctionResult = (functionResult !=  null) ? LocalDate.parse(functionResult.toString(), dateFormatter) : null;
        LocalDate nowForDate = LocalDate.now();
        String secondaryDateValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;
        switch (r.getDataTypeRequirementId().intValue()) {
          case 1:
            try {
              Assert.notNull(secondaryDateValue, "Unable to determine secondary value");
              passed = compareDates(dateFunctionResult, nowForDate.minusDays(Long.parseLong(secondaryDateValue)), r.getOperatorTypeId());
            } catch (NumberFormatException e) {
              //@TODO: something
            }
            break;
          case 2:
            try {
              Assert.notNull(secondaryDateValue, "Unable to determine secondary value");
              passed = compareDates(dateFunctionResult, nowForDate.plusDays(Long.parseLong(secondaryDateValue)), r.getOperatorTypeId());
            } catch (NumberFormatException e) {
              //@TODO: something?
            }
            break;
          case 3:
            passed = compareDates(dateFunctionResult, nowForDate, r.getOperatorTypeId());
            break;
          case 4:
            try {
              passed = compareNullDate(dateFunctionResult, r.getOperatorTypeId());
            } catch (IllegalArgumentException e) {
              //@TODO: something?
            }
            break;
          case 5:
            try {
              passed = compareNonNullDate(dateFunctionResult, r.getOperatorTypeId());
            } catch (IllegalArgumentException e) {
              //@TODO: something?
            }
            break;
        }
        break;
      case 2:
        // @TODO: Duped from the button logic, potentially combine
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.n");
        LocalDateTime timestampFunctionResult = (functionResult !=  null) ? LocalDateTime.parse(functionResult.toString(), dateTimeFormatter).withMinute(0).withSecond(0).withNano(0) : null;
        LocalDateTime nowForTimestamp =  LocalDateTime.now().withMinute(0).withSecond(0).withNano(0);
        String secondaryTimestampValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;
        switch (r.getDataTypeRequirementId().intValue()) {
          case 6:
            try {
              Assert.notNull(secondaryTimestampValue, "Unable to determine secondary value");
              passed = compareDates((timestampFunctionResult != null) ? timestampFunctionResult.toLocalDate() : null, nowForTimestamp.minusDays(Long.parseLong(secondaryTimestampValue)).toLocalDate(), r.getOperatorTypeId());
            } catch (NumberFormatException e) {
              //@TODO: something
            }
            break;
          case 7:
            try {
              Assert.notNull(secondaryTimestampValue, "Unable to determine secondary value");
              passed = compareDates((timestampFunctionResult != null) ? timestampFunctionResult.toLocalDate() : null, nowForTimestamp.plusDays(Long.parseLong(secondaryTimestampValue)).toLocalDate(), r.getOperatorTypeId());
            } catch (NumberFormatException e) {
              //@TODO: something
            }
            break;
          case 8:
            passed = compareDates((timestampFunctionResult != null) ? timestampFunctionResult.toLocalDate() : null, nowForTimestamp.toLocalDate(), r.getOperatorTypeId());
            break;
          case 9:
            try {
              Assert.notNull(secondaryTimestampValue, "Unable to determine secondary value");
              passed = compareDateTimes(timestampFunctionResult, nowForTimestamp.minusHours(Long.parseLong(secondaryTimestampValue)), r.getOperatorTypeId());
            } catch (NumberFormatException e) {
              //@TODO: something
            }
            break;
          case 10:
            try {
              Assert.notNull(secondaryTimestampValue, "Unable to determine secondary value");
              passed = compareDateTimes(timestampFunctionResult, nowForTimestamp.plusHours(Long.parseLong(secondaryTimestampValue)), r.getOperatorTypeId());
            } catch (NumberFormatException e) {
              //@TODO: something
            }
            break;
          case 11:
            passed = compareDateTimes(timestampFunctionResult, nowForTimestamp, r.getOperatorTypeId());
            break;
          case 12:
            try {
              passed = compareNullDateTime(timestampFunctionResult, r.getOperatorTypeId());
            } catch (IllegalArgumentException e) {
              //@TODO: something?
            }
            break;
          case 13:
            try {
              passed = compareNonNullDateTime(timestampFunctionResult, r.getOperatorTypeId());
            } catch (IllegalArgumentException e) {
              //@TODO: something?
            }
        }
        break;
      case 3:
        // @TODO: Duped from the button logic, potentially combine
        Boolean booleanFunctionResult = Boolean.valueOf(functionResult.toString());
        switch (r.getDataTypeRequirementId().intValue()) {
          case 14:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = booleanFunctionResult != null && booleanFunctionResult;
                break;
              case 2:
                passed = booleanFunctionResult == null || !booleanFunctionResult;
              case 3:
              case 4:
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Boolean with operator of ID: %s", r.getOperatorTypeId()));
            }
            break;
          case 15:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = booleanFunctionResult != null && !booleanFunctionResult;
                break;
              case 2:
                passed = booleanFunctionResult == null || booleanFunctionResult;
              case 3:
              case 4:
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Boolean with operator of ID: %s", r.getOperatorTypeId()));
            }
            break;
          default:
            throw new Exception(String.format("Unable to parse data type of Boolean with data type requirement of ID: %s", r.getDataTypeRequirementId()));
        }
        break;
      case 4:
        // @TODO: Duped from the button logic, potentially combine
        Double numericFunctionResult = (functionResult == null) ? null : new BigDecimal(functionResult.toString()).setScale(2, RoundingMode.DOWN).doubleValue();
        switch(r.getDataTypeRequirementId().intValue()) {
          case 16:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = numericFunctionResult == null;
                break;
              case 2:
                passed = numericFunctionResult != null;
                break;
              case 3:
              case 4:
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
            }
            break;
          case 17:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = numericFunctionResult != null;
                break;
              case 2:
                passed = numericFunctionResult == null;
                break;
              case 3:
              case 4:
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
            }
            break;
        }
        break;
      case 5:
        // @TODO: Duped from the button logic, potentially combine
        String stringFunctionResult = (functionResult != null) ? functionResult.toString() : null;
        // An empty string and null are treated as the same value during text comparison
        switch (r.getDataTypeRequirementId().intValue()) {
          case 18:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = stringFunctionResult == null || stringFunctionResult.isEmpty();
                break;
              case 2:
                passed = stringFunctionResult != null && !stringFunctionResult.isEmpty();
                break;
              case 3:
              case 4:
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
            }
            break;
          case 19:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = stringFunctionResult != null && !stringFunctionResult.isEmpty();
                break;
              case 2:
                passed = stringFunctionResult == null || stringFunctionResult.isEmpty();
                break;
              case 3:
              case 4:
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
            }
        }
        break;
      case 6:
      case 9:
        Long intFunctionResult = (functionResult != null) ? Long.valueOf(functionResult.toString()) : null;
        switch(r.getDataTypeRequirementId().intValue()) {
          case 20:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = intFunctionResult == null;
                break;
              case 2:
                passed = intFunctionResult != null;
                break;
              case 3:
              case 4:
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
            }
            break;
          case 21:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = intFunctionResult != null;
                break;
              case 2:
                passed = intFunctionResult == null;
                break;
              case 3:
              case 4:
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
            }
            break;
        }
        break;
      case 7:
        break;
      default:

    }
    return passed;
  }

  public String[] prepareFunctionParams(List<CompanyFunctionParam> functionParams, Long projectId) throws Exception {
    Map<Long, String> params = new TreeMap<>();

    functionParams.forEach(param -> {
      switch (param.getParameterTypeId().intValue()) {
        case 1:
          Long systemValue = null;
          switch (param.getSystemValueId().intValue()) {
            case 1:
              systemValue = securityService.getCurrentUser().getId();
              break;
            case 2:
              systemValue = projectId;
              break;
            default:
              //@TODO: die a horrible death
          }
          params.put(param.getDisplayOrder(), systemValue != null ? systemValue.toString() : null);
          break;
        case 2:
          params.put(param.getDisplayOrder(), param.getDynamicValue());
          break;
        case 3:
          try {
            Object paramValue = getParamValueByDataType(param);
            params.put(param.getDisplayOrder(), (paramValue != null) ? paramValue.toString() : null);
          } catch (Exception e) {
            ///@TODO: throw ex
          }
          break;
        default:
          //@TODO: throw exception
      }
    });

    return params.values().toArray(String[]::new);
  }

//  public Object getTypedDynamicValue(CompanyFunctionParam param) {
//
//    String startingValue = param.getDynamicValue();
//    Object typedValue = null;
//
//    try {
//      switch (param.getDataTypeId().intValue()) {
//        case 1:
//        case 2:
//          typedValue = Timestamp.valueOf(startingValue);
//          break;
//        case 3:
//          typedValue = Boolean.parseBoolean(startingValue);
//          break;
//        case 4:
//          typedValue = Double.parseDouble(startingValue);
//          break;
//        case 5:
//          typedValue = startingValue;
//          break;
//        case 6:
//          typedValue = Long.parseLong(startingValue);
//          break;
//        default:
//
//      }
//    } catch (Exception e) {
//      //@TODO: die here
//    }
//
//    return typedValue;
//  }

  public Object getParamValueByDataType(CompanyFunctionParam param) throws Exception {

    Object paramValue = null;

    switch (param.getDataTypeId().intValue()) {
      case 1:
        paramValue = param.getDateValue();
        break;
      case 2:
        paramValue = param.getTimestampValue();
        break;
      case 3:
        paramValue = param.getBooleanValue();
        break;
      case 4:
        paramValue = param.getNumericValue();
        break;
      case 5:
        paramValue = param.getTextValue();
        break;
      case 6:
        paramValue = param.getIntValue();
        break;
      case 7:
        paramValue = param.getIntArrayValue();
        break;
      default:
        //@TODO: throw nasty exception
    }

    return paramValue;
  }

  public boolean calculateMultiselectRequirement(ProjectProcessStepRequirement r) throws Exception {

    List<Integer> fieldValue = r.getIntArrayValue();

    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        List<Integer> reqValue = r.getListOfValueIds();
        passed = compareMultiselect(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (Exception e) {
        throw new Exception(String.format("Unable to parse data type of Multiselect with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 22:
          passed = fieldValue.isEmpty();
          break;
        case 23:
          passed = !fieldValue.isEmpty();
          break;
        default:
          throw new Exception(String.format("Unable to parse data type of Multiselect with operator of ID: %s", r.getOperatorTypeId()));
      }

      if (r.getOperatorTypeId() == 2) {
          passed = !passed;
      }
    }
    return passed;
  }

  public boolean compareMultiselect(List<Integer> numbers, List<Integer> compareNumbers, Long operatorTypeId) throws Exception {

    boolean passed = false;
    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(numbers, compareNumbers);
        break;
      case 2:
        passed = !Objects.equals(numbers, compareNumbers);
        break;
      case 5:
        List<Integer> intersection = numbers.stream().filter(compareNumbers::contains).collect(Collectors.toList());
        passed = !intersection.isEmpty();
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Multiselect with operator of ID: %s", operatorTypeId));
    }
    return passed;
  }

  public boolean caclulateDropdownRequirement(ProjectProcessStepRequirement r) throws Exception {

    Long fieldValue = r.getIntValue();

    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        Long reqValue = r.getListOfValueId();
        passed = compareDropdown(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (Exception e) {
        throw new Exception(String.format("Unable to parse data type of Dropdown with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 20:
        case 26:
            switch (r.getOperatorTypeId().intValue()) {
                case 1:
                    passed = fieldValue == null;
                    break;
                case 2:
                    passed = fieldValue != null;
                    break;
                case 3:
                case 4:
                    break;
                default:
                    throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
            }
            break;
        case 21:
        case 27:
            switch (r.getOperatorTypeId().intValue()) {
                case 1:
                    passed = fieldValue != null;
                    break;
                case 2:
                    passed = fieldValue == null;
                    break;
                case 3:
                case 4:
                    break;
            }
          break;
        default:
          throw new Exception(String.format("Unable to parse data type of Dropdown with operator of ID: %s", r.getOperatorTypeId()));
      }
    }

    return passed;
  }

  public boolean compareDropdown(Long number, Long compareNumber, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(number, compareNumber);
        break;
      case 2:
        passed = !Objects.equals(number, compareNumber);
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Dropdown with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  public boolean calculateIntRequirement(ProjectProcessStepRequirement r) throws Exception {

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
      switch(r.getDataTypeRequirementId().intValue()) {
        case 20:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue == null;
              break;
            case 2:
              passed = fieldValue != null;
              break;
            case 3:
            case 4:
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
          }
          break;
        case 21:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue != null;
              break;
            case 2:
              passed = fieldValue == null;
              break;
            case 3:
            case 4:
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
          }
          break;
      }
    }

    return passed;
  }

  public boolean compareInt(Long number, Long compareNumber, Long operatorTypeId) throws Exception {

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

  public boolean calculateTextRequirement(ProjectProcessStepRequirement r) throws Exception {

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
      // An empty string and null are treated as the same value during text comparison
      switch (r.getDataTypeRequirementId().intValue()) {
        case 18:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue == null || fieldValue.isEmpty();
              break;
            case 2:
              passed = fieldValue != null && !fieldValue.isEmpty();
              break;
            case 3:
            case 4:
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
          }
          break;
        case 19:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue != null && !fieldValue.isEmpty();
              break;
            case 2:
              passed = fieldValue == null || fieldValue.isEmpty();
              break;
            case 3:
            case 4:
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
          }
      }
    }
    return passed;
  }

  public boolean compareText(String text, String compareText, Long operatorTypeId) throws Exception {

    boolean passed = false;

    // Treat empty strings and null the same
    text = (text != null) ? text.trim().toLowerCase() : "";
    compareText = (compareText != null) ? compareText.trim().toLowerCase() : "";

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = text.equals(compareText);
        break;
      case 2:
        passed = !text.equals(compareText);
        break;
      case 3:
      case 4:
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  public boolean calculateNumericRequirement(ProjectProcessStepRequirement r) throws Exception {

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
            case 3:
            case 4:
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
            case 3:
            case 4:
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
          }
          break;
      }
    }

    return passed;
  }

  public boolean compareNumeric(Double number, Double compareNumber, Long operatorTypeId) throws Exception {

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

  public boolean calculateBooleanRequirement(ProjectProcessStepRequirement r) throws Exception {

    Boolean fieldValue = r.getBooleanValue();

    boolean passed = false;

    switch (r.getDataTypeRequirementId().intValue()) {
      case 14:
        switch (r.getOperatorTypeId().intValue()) {
          case 1:
            passed = fieldValue != null && fieldValue;
            break;
          case 2:
            passed = fieldValue == null || !fieldValue;
          case 3:
          case 4:
            break;
          default:
            throw new Exception(String.format("Unable to parse data type of Boolean with operator of ID: %s", r.getOperatorTypeId()));
        }
        break;
      case 15:
        switch (r.getOperatorTypeId().intValue()) {
          case 1:
            passed = fieldValue != null && !fieldValue;
            break;
          case 2:
            passed = fieldValue == null || fieldValue;
          case 3:
          case 4:
            break;
          default:
            throw new Exception(String.format("Unable to parse data type of Boolean with operator of ID: %s", r.getOperatorTypeId()));
        }
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Boolean with data type requirement of ID: %s", r.getDataTypeRequirementId()));
    }

    return passed;
  }

  public boolean calculateTimestampRequirement(ProjectProcessStepRequirement r) throws Exception {

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
            passed = compareDates((fieldValue != null) ? fieldValue.toLocalDate() : null, now.minusDays(Long.parseLong(secondaryValue)).toLocalDate(), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 7:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates((fieldValue != null) ? fieldValue.toLocalDate() : null, now.plusDays(Long.parseLong(secondaryValue)).toLocalDate(), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 8:
          passed = compareDates((fieldValue != null) ? fieldValue.toLocalDate() : null, now.toLocalDate(), r.getOperatorTypeId());
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
            passed = compareNullDateTime(fieldValue, r.getOperatorTypeId());
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
        case 13:
          try {
            passed = compareNonNullDateTime(fieldValue, r.getOperatorTypeId());
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
      }
    }

    return passed;
  }

  public boolean compareNullDateTime(LocalDateTime date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date == null;
        break;
      case 2:
        passed = date != null;
        break;
      case 3:
      case 4:
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  public boolean compareNonNullDateTime(LocalDateTime date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date != null;
        break;
      case 2:
        passed = date == null;
        break;
      case 3:
      case 4:
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  public boolean compareDateTimes(LocalDateTime date, LocalDateTime compareDate, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(date, compareDate);
        break;
      case 2:
        passed = !Objects.equals(date, compareDate);
        break;
      case 3:
        passed = date != null && date.isAfter(compareDate);
        break;
      case 4:
        passed = date != null && date.isBefore(compareDate);
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  public boolean calculateDateRequirement(ProjectProcessStepRequirement r) throws Exception {

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
            passed = compareNullDate(fieldValue, r.getOperatorTypeId());
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
        case 5:
          try {
            passed = compareNonNullDate(fieldValue, r.getOperatorTypeId());
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
      }
    }

    return passed;
  }

  public boolean compareNonNullDate(LocalDate date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date != null;
        break;
      case 2:
        passed = date == null;
        break;
      case 3:
      case 4:
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  public boolean compareNullDate(LocalDate date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date == null;
        break;
      case 2:
        passed = date != null;
        break;
      case 3:
      case 4:
        passed = false;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  public boolean compareDates(LocalDate date, LocalDate compareDate, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(date, compareDate);
        break;
      case 2:
        passed = !Objects.equals(date, compareDate);
        break;
      case 3:
        passed = date != null && date.isAfter(compareDate);
        break;
      case 4:
        passed = date != null && date.isBefore(compareDate);
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Date with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }
}
