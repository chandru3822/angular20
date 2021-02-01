package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.SystemSettings;
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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.Assert;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
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

  private final ProjectService projectService;

  private final AttachmentService attachmentService;

  private final AmazonS3 s3;

  private final ProcessStepActionService processStepActionService;

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

    //had to change this so that a parent looking at a child project could still see project statuses
    HashMap<String, Object> p2 = new HashMap<>();
    p2.put("projectProcessStepId", projectProcessStepId);
    Long companyId = sqlCache.queryForObject("projectProcessStep.getCompanyId", p2, Long.class);

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
    params.put("filename", CleanString.cleanFilename(file.getOriginalFilename()));
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("createdById", user.getId());
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("companyId", companyId);

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

    params.clear();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", user.getId());

    sqlCache.update("projectProcessStep.addAttachment", params);

    return attachmentService.findById(attachmentId);
  }

  public void setStatus(Long projectProcessStepId, Long processStepStatusTypeId, Long companyProcessStepStatusTypeId, boolean runAutoTriggers, Long cancelledStatusTypeId) {
    User user = securityService.getCurrentUser();
    ProjectProcessStep pps = getProjectProcessStep(projectProcessStepId);

    if (pps == null) {
        throw new RuntimeException("The given process step does not exist");
    }


    if (pps.getCompanyProcessStepStatusTypeId().equals(companyProcessStepStatusTypeId)) {
        return;
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", pps.getProjectProcessStepId());
    params.put("processStepStatusTypeId", processStepStatusTypeId);
    params.put("companyProcessStepStatusTypeId", companyProcessStepStatusTypeId);
    params.put("userId", user.getId());
    params.put("projectId", pps.getProjectId());
    params.put("processStepId", pps.getProcessStepId());
    params.put("main", pps.getMain());
//    this determines what is done with existing actives of the same process step
    params.put("cancelledStatusTypeId", cancelledStatusTypeId);

    sqlCache.query("projectProcessStep.setStatus", params, String.class);
    //check for un-run automatic actions if the new status type is active
    if(runAutoTriggers && processStepStatusTypeId == 1) {
      performAutoTriggerActions(projectProcessStepId, securityService.getCurrentUserDetails());
    }
  }

  public void setProjectStatus(Long projectId, Long companyProjectStatusTypeId, boolean runAutoTriggers) {
    Optional<Project> prj = projectService.getProject(projectId);

    if (prj.isEmpty()) {
      throw new RuntimeException("The given project does not exist");
    }

    // project status is already set to the desired status
    if (prj.get().getCompanyProjectStatusTypeId().equals(companyProjectStatusTypeId)) {
      return;
    }

    // set the project status to the desired status
    projectService.updateStatus(projectId, companyProjectStatusTypeId);

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
    try {
        String json = sqlCache.queryForObject("projectProcessStep.getProjectProcessStep", Map.of("stepId", stepId), String.class);
        if(null != json) {
          return om.readValue(json, new TypeReference<>(){});
        } else {
          throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Project Process Step Not Found", new Exception());
        }
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Project Process Step Not Found", new Exception());
    }
  }

  public Long insertProjectProcessStep(Long projectId, Long processStepId, Long userPositionId, Long parentProjectProcessStepId, boolean performAutoTrigger, Long companyProcessStepStatusTypeId) {
    User user = securityService.getCurrentUser();
    Long companyId = user.getCompanyId();

    if(null != projectId) {
      //had to change this so that a parent looking at a child project could still see right statuses
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      companyId = sqlCache.queryForObject("project.getCompanyId", params, Long.class);
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("processStepId", processStepId);
    params.put("userPositionId", userPositionId);
    params.put("userId", user.getId());
    params.put("companyId", companyId);
    params.put("parentProjectProcessStepId", parentProjectProcessStepId);
    params.put("companyProcessStepStatusTypeId", companyProcessStepStatusTypeId);

    Long ppsId =  sqlCache.queryForObject("projectProcessStep.insertProjectProcessStep", params, Long.class);

    if (performAutoTrigger) {
      this.performAutoTriggerActions(ppsId, securityService.getCurrentUserDetails());
    }

    return ppsId;
  }

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

      TypeReference<List<ProcessStepAction> > actionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "actions", new JsonCollectionDeserializer(actionsRef, objectMapper));

      TypeReference<List<ProjectProcessStepRequirement>> requirementsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "autoTriggeredActionRequirements", new JsonCollectionDeserializer(requirementsRef, objectMapper));
    }
  }

  public List<Owner> getOwners(Long processStepProcessId) {
    return sqlCache.query("projectProcessStep.getOwners", Map.of("processStepProcessId", processStepProcessId), Owner.class);
  }

  public List<Long> getIdsForAutoTriggerByCfgaIds(Long projectId, Long contactId, List<Long> cfgaIds) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      params.put("contactId", contactId);
      params.put("cfgaIds", cfgaIds);
      return sqlCache.query("projectProcessStep.getIdsByAutoTriggerActionsAndReqs", params, new SingleColumnRowMapper<>(Long.class));
  }
  /************************************************************* ACTION LOGIC ********************************************************************************/

  public List<Long> performInitialAutoTriggers() {

    User cronUser = new User();
    cronUser.setId(SystemSettings.CRON_USER.getId());

    final List<Map<String, Object>> results = sqlCache.query("projectProcessStep.getInitialAutoTriggerPps", null, new ColumnMapRowMapper());

    List<Long> createdPpsIds = new ArrayList<>();

    for(Map<String, Object> result: results) {
      cronUser.setCompanyId(Long.valueOf(result.get("companyId").toString()));
      List<Long> newPpsIds = performAutoTriggerActions(Long.valueOf(result.get("ppsId").toString()), new UserAccountDetails(cronUser, Collections.emptyList()));
      if (!newPpsIds.isEmpty()) {
        createdPpsIds.addAll(newPpsIds);
      }
    }

    log.info("TRIGGERS: PPSs created by initial auto triggers: " + createdPpsIds.size());
    log.info("TRIGGERS: PPS ids created by initial auto triggers: " + createdPpsIds);

    return createdPpsIds;
  }

  public void performTimeBasedAutoTriggers() {

    User cronUser = new User();
    cronUser.setId(SystemSettings.CRON_USER.getId());

    final List<Map<String, Object>> results = sqlCache.query("projectProcessStep.getTimeBasedAutoTriggerPps", null, new ColumnMapRowMapper());

    List<Long> createdPpsIds = new ArrayList<>();

    for(Map<String, Object> result: results) {
      cronUser.setCompanyId(Long.valueOf(result.get("companyId").toString()));
      List<Long> newPpsIds = performAutoTriggerActions(Long.valueOf(result.get("ppsId").toString()), new UserAccountDetails(cronUser, Collections.emptyList()));
      if (!newPpsIds.isEmpty()) {
        createdPpsIds.addAll(newPpsIds);
      }
    }

    log.info("TRIGGERS: PPS created by time based auto triggers: " + createdPpsIds.size());
    log.info("TRIGGERS: PPS ids created by time based auto triggers: " + createdPpsIds);
  }

  @Transactional
  public List<Long> performAutoTriggerActions(Long ppsId, UserAccountDetails userDetails) {
      // Set the security context so we have user details in the async downline
      securityService.setCurrentUserDetails(userDetails);

      ProjectProcessStep pps = this.getProjectProcessStep(ppsId);

      ArrayList<Long> createdPpsIds = new ArrayList<>();

      if (pps.getProcessStepStatusTypeId() == 1) {
          pps.getActions().forEach(action -> {
              if (action.getTriggerAutomatically() && !action.getAlreadyTriggered()) {
                  try {
                      List<Long> reqIds = action.getProcessStepLogicList().stream()
                          .filter(step -> step.getProcessStepRequirementId() != null)
                          .map(ProcessStepLogic::getProcessStepRequirementId)
                          .collect(Collectors.toList());

                      List<ProjectProcessStepRequirement> reqs = pps.getAutoTriggeredActionRequirements().stream()
                          .filter(r -> reqIds.contains(r.getId()))
                          .collect(Collectors.toList());
                    ProjectProcessStepAction actionResult = this.canPerformAction(action, pps, reqs);
                      if (actionResult.getCanPerform()) {
                          List<Long> newPpsIds = this.performAction(action, pps);
                          if (!newPpsIds.isEmpty()) {
                            createdPpsIds.addAll(newPpsIds);
                          }
                      }
                  } catch (Exception e) {
                      log.error(String.format("PPS: Unable to automatically trigger action ID: %s, with project process step ID: %s",  action.getId(), ppsId));
                  }
              }
          });
      }
      return createdPpsIds;
  }

  @Transactional
  public List<Long> performAction(ProcessStepAction action, ProjectProcessStep pps) {
    /*
     **High level pseudo logic:**

     * transaction all queries so current state is kept on any errors
     * Performance will be key here as it will be hit a lot and business logic will grow

     * gather required data
     * set the parent step to the specified status
     * set them to the active status
     * recursively check if child processes have children and auto-triggered until all auto-triggered child process steps have been created with active statuses
     */

    User user = securityService.getCurrentUser();
    if (action.getCompanyProcessStepStatusTypeId() != null) {
      this.setStatus(pps.getProjectProcessStepId(), action.getProcessStepStatusTypeId(), action.getCompanyProcessStepStatusTypeId(), false, null);
    }

    //update project status if needed
    if (action.getCompanyProjectStatusTypeId() != null) {
      this.setProjectStatus(pps.getProjectId(), action.getCompanyProjectStatusTypeId(), false);
    }

    performChildFunctions(action.getId(), pps.getProjectProcessStepId(), pps.getProcessStepId());

    ArrayList<Long> createdPpsIds = new ArrayList<>();

    action.getProcessStepActionChildProcesses().forEach(childStep -> {
      Long ppsId = this.insertProjectProcessStep(pps.getProjectId(), childStep.getProcessStepId(), null, pps.getProjectProcessStepId(), false, childStep.getCompanyProcessStepStatusTypeId());
      createdPpsIds.add(ppsId);
      if (childStep.getAutoTriggerActionCount() > 0) {
          this.performAutoTriggerActions(ppsId, securityService.getCurrentUserDetails());
      }
    });

    sqlCache.update("projectProcessStep.insertPerformedAction", Map.of("ppsId", pps.getProjectProcessStepId(),
      "psaId", action.getId(), "autoTriggered", action.getTriggerAutomatically(), "createdById", user.getId(), "allowMultipleUses", action.getMultipleUses()));

    return createdPpsIds;
  }

  public ProjectProcessStepAction canPerformAction(ProjectProcessStepAction action, ProjectProcessStep pps, List<ProjectProcessStepRequirement> requirements) throws Exception {
    // Allow actions to be triggered only once per PPS
    if (action.getAlreadyTriggered() && !action.getMultipleUses()) {
        action.setCanPerform(false);
        return action;
    }

    // Only perform actions on active project process steps
    if (pps.getProcessStepStatusTypeId() != 1) {
      action.setCanPerform(false);
      return action;
    }

    if (action.getAlwaysEnabled()) {
      action.setCanPerform(true);
      return action;
    }

    if (action.getProcessStepLogicList().isEmpty()) {
      action.setCanPerform(false);
      return action;
    }

    // If there are not any requirements, then it can be completed
    if (requirements.isEmpty()) {
      action.setCanPerform(true);
      return action;
    }

    // Check to if individual requirements are fulfilled
    for (ProjectProcessStepRequirement r: requirements) {
      try {
        r.setFulfilled(this.isRequirementMet(r, pps.getProjectProcessStepId()));
      } catch (Exception e) {
        log.error(String.format("PPS: Exception while parsing date requirement value for process step requirement ID: %s", r.getId()));
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
      // @TODO: humes, This is for debugging purposes
//      final String tempString = logicString.toString().replaceAll("AND", "&&").replaceAll("OR", "||");
//      log.info(String.format("Logic string generated for actionId: %s, ppsId: %s, %s", action.getId(), pps.getProjectProcessStepId(), tempString));
//      log.info("hi" + parser.parseExpression(logicString.toString()).getValue(Boolean.class));
      action.setCanPerform(parser.parseExpression(logicString.toString()).getValue(Boolean.class));
      return action;
    } else {
      action.setCanPerform(requirements.stream().allMatch(ProcessStepRequirement::getFulfilled));
      return action;
    }
  }

  // It's assumed for date data types that it's always a data_type_requirement and never a literal comparison of values
  public boolean isRequirementMet(ProjectProcessStepRequirement r, Long ppsId) throws Exception {

    boolean requirementMet = false;

    if (r.getProcessStepRequirementTypeId() == 2) {
      String params = String.join(", ", prepareFunctionParams(r.getCompanyFunctionParams(), r.getProjectId(), r.getProcessStepId(), ppsId));
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
        Boolean booleanFunctionResult = (functionResult == null) ? null : Boolean.valueOf(functionResult.toString());
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

    public void performChildFunctions(Long actionId, Long ppsId, Long processStepId) {
        List<ProcessStepActionChildFunction> childFunctions = processStepActionService.getChildFunctionsWithParamValues(actionId, ppsId);
        childFunctions.forEach(childFunction -> {
            try {
                String params = String.join(", ", prepareFunctionParams(childFunction.getCompanyFunctionParams(), childFunction.getProjectId(), processStepId, ppsId));
                String query = String.format("select * from %s(%s)", childFunction.getFunctionName(), params);
                sqlCache.getBySql(query, null, new SingleColumnRowMapper<>(Object.class));
            } catch (Exception e) {
                log.error(String.format("PPS: Unable to run child action function. CFA ID: %s, action ID: %s", childFunction.getId(), actionId));
                e.printStackTrace();
            }
        });

        if (!childFunctions.isEmpty()) {
          // I have a suspicion that there is a potential bug here. If this function was auto triggered, this will potentially double run auto triggers on some
          // PPS actions. Not sure if that will cause an issue, or only run unnecessary logic
          this.performAutoTriggerActions(ppsId, securityService.getCurrentUserDetails());
        }
    }

  public String[] prepareFunctionParams(List<CompanyFunctionParam> functionParams, Long projectId, Long processStepId, Long ppsId) throws Exception {
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
            case 3:
              systemValue = ppsId;
              break;
            case 4:
              systemValue = processStepId;
              break;
            default:
              //@TODO: die a horrible death
          }
          params.put(param.getDisplayOrder(), systemValue != null ? systemValue.toString() : null);
          break;
        case 2:
          params.put(param.getDisplayOrder(), getTypedDynamicValue(param).toString());
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

  public Object getTypedDynamicValue(CompanyFunctionParam param) {

    String startingValue = param.getDynamicValue();
    Object typedValue = null;

    try {
      switch (param.getDataTypeId().intValue()) {
        case 1:
        case 2:
          typedValue = Timestamp.valueOf(startingValue);
          break;
        case 3:
          typedValue = Boolean.parseBoolean(startingValue);
          break;
        case 4:
          typedValue = Double.parseDouble(startingValue);
          break;
        case 5:
          typedValue = "'" + startingValue + "'";
          break;
        case 6:
          typedValue = Long.parseLong(startingValue);
          break;
        default:

      }
    } catch (Exception e) {
      //@TODO: die here
    }

    return typedValue;
  }

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
