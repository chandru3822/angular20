package com.albatross.api.v1.flow.services;

import com.albatross.api.aurora.AuroraProxy;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.BrsProcessStepActionFunctionService;
import com.albatross.api.v1.company.blueraven.services.GoodleapService;
import com.albatross.api.v1.company.blueraven.services.MarketoService;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.function.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.processStep.*;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.model.projectProcessStep.*;
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
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;


//@TODO: Had to make private functions public in this class to be able to unit test due to this issue. https://github.com/powermock/powermock/issues/929
// I don't like it and would rather have them be private. Change back if/when possible

@Slf4j
@Service
@RequiredArgsConstructor
public class ProjectProcessStepService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ProjectService projectService;
  private final AttachmentService attachmentService;
  private final AmazonS3 s3;
  private final ProcessStepActionService processStepActionService;
  private final ObjectMapper om;
  private final ProjectProcessStepRequirementService projectProcessStepRequirementService;
  private final CustomFieldValueService customFieldValueService;
  private final GoodleapService goodleapService;
  private final AuroraProxy auroraService;
  private final MarketoService marketoService;
  private final ListOfValueService listOfValueService;

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
    params.put("createdById", user.trueUserId());
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("companyId", companyId);

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

    params.clear();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", user.trueUserId());

    sqlCache.update("projectProcessStep.addAttachment", params);

    return attachmentService.findById(attachmentId);
  }

  public void removeOwner(Long projectProcessStepId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("userId", user.trueUserId());

    sqlCache.update("projectProcessStep.removeOwner", params);
  }

  public void setStatus(Long projectProcessStepId, Long processStepStatusTypeId, Long companyProcessStepStatusTypeId, Long cancelledCompanyProcessStepStatusTypeId) {
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
    params.put("userId", user.trueUserId());
    params.put("projectId", pps.getProjectId());
    params.put("processStepId", pps.getProcessStepId());
    params.put("cancelledStatusTypeId", cancelledCompanyProcessStepStatusTypeId);

    sqlCache.query("projectProcessStep.setStatus", params, String.class);
  }

  public void setMain(Long ppsId, CompanyProcessStepStatusType status) {
    Map<String, Object> params = new HashMap<>();
    params.put("ppsId", ppsId);
    params.put("activeCompanyProcessStepStatusTypeId", status.getId());
    params.put("cancelledCompanyProcessStepStatusTypeId", status.getCancelledCompanyProcessStepStatusTypeId());
    params.put("userId", securityService.getCurrentUser().getId());
    sqlCache.query("projectProcessStep.setMain", params, String.class);
  }

  public void setProjectStatus(Long projectId, Long companyProjectStatusTypeId) {
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
    User user = securityService.getCurrentUser();

    try {
        String json = sqlCache.queryForObject("projectProcessStep.getProjectProcessStep", Map.of("stepId", stepId, "companyId", user.getCompanyId()), String.class);
        if(null != json) {
          return om.readValue(json, new TypeReference<>(){});
        } else {
          throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Project Process Step Not Found", new Exception());
        }
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Project Process Step Not Found", e);
    }
  }

  public ProjectProcessStepStatus getProjectProcessStepStatus(Long stepId) {
    Optional <ProjectProcessStepStatus> status = sqlCache.get("projectProcessStep.getStatus", Map.of("stepId", stepId), ProjectProcessStepStatus.class);
    return status.orElse(null);
  }

  public Long insertProjectProcessStep(Long projectId, Long processStepId, Long userPositionId, Long parentProjectProcessStepId, boolean performAutoTrigger, Long initialCompanyProcessStepStatusTypeId, Long existingCompanyProcessStepStatusTypeId) {
    var ppsId = this.insertProjectProcessStep(projectId, processStepId, userPositionId, parentProjectProcessStepId, initialCompanyProcessStepStatusTypeId, existingCompanyProcessStepStatusTypeId);
    if (performAutoTrigger) {
      this.performAutoTriggerActions(ppsId, securityService.getCurrentUserDetails());
    }
    return ppsId;
  }

  public Long insertProjectProcessStep(Long projectId, Long processStepId, Long userPositionId, Long parentProjectProcessStepId, Long initialCompanyProcessStepStatusTypeId, Long existingCompanyProcessStepStatusTypeId) {
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
    params.put("userId", user.trueUserId());
    params.put("companyId", companyId);
    params.put("parentProjectProcessStepId", parentProjectProcessStepId);
    params.put("initialCompanyProcessStepStatusTypeId", initialCompanyProcessStepStatusTypeId);
    params.put("existingCompanyProcessStepStatusTypeId", existingCompanyProcessStepStatusTypeId);

    return sqlCache.queryForObject("projectProcessStep.insertProjectProcessStep", params, Long.class);
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

  public List<ProjectProcessStepHistory> getPpsHistory(Long projectProcessStepId) {
    List<ProjectProcessStepHistory> results = sqlCache.query("projectProcessStep.getHistory", Map.of("projectProcessStepId", projectProcessStepId), ProjectProcessStepHistory.class);
    return results;
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

      TypeReference<List<ProjectProcessStepEvent>> ppsEventsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "projectProcessStepEvents", new JsonCollectionDeserializer(ppsEventsRef, objectMapper));
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

  public ProjectProcessStepAction getActionResult(Long actionId, Long ppsId) throws Exception {
    ProjectProcessStep pps = getProjectProcessStep(ppsId);
    ProjectProcessStepAction action = pps.getActions().stream().filter(a -> a.getId().equals(actionId)).findFirst().orElse(null);
    return getActionResult(actionId, action, pps);
  }

  public ProjectProcessStepAction getActionResult(Long actionId, ProjectProcessStepAction action, ProjectProcessStep pps) throws Exception {

    List<Long> requirementIds = Objects.requireNonNull(action).getProcessStepLogicList().stream()
      .filter(step -> step.getProcessStepRequirementId() != null)
      .map(ProcessStepLogic::getProcessStepRequirementId)
      .collect(Collectors.toList());
    List<ProjectProcessStepRequirement> requirements = projectProcessStepRequirementService.getByProjectProcessStepId(pps.getProjectProcessStepId(), requirementIds);
    ProjectProcessStepAction actionResult = canPerformAction(action, pps, requirements);

    ProjectProcessStepAction minimalResult = new ProjectProcessStepAction();

    minimalResult.setId(actionId);
    minimalResult.setActionName(actionResult.getActionName());
    minimalResult.setCanPerform(pps.getProcessStepStatusTypeId() == 1 && actionResult.getCanPerform());
    minimalResult.setMultipleUses(actionResult.getMultipleUses());
    minimalResult.setAlreadyTriggered(actionResult.getAlreadyTriggered());
    minimalResult.setTriggerAutomatically(actionResult.getTriggerAutomatically());

    return actionResult;
  }
  /************************************************************* ACTION LOGIC ********************************************************************************/

//  public List<Long> performInitialAutoTriggers() {
//
//    User cronUser = new User();
//    cronUser.setId(SystemSettings.CRON_USER.getId());
//
//    final List<Map<String, Object>> results = sqlCache.query("projectProcessStep.getInitialAutoTriggerPps", null, new ColumnMapRowMapper());
//
//    List<Long> createdPpsIds = new ArrayList<>();
//
//    for(Map<String, Object> result: results) {
//      cronUser.setCompanyId(Long.valueOf(result.get("companyId").toString()));
//      List<Long> newPpsIds = performAutoTriggerActions(Long.valueOf(result.get("ppsId").toString()), new UserAccountDetails(cronUser, Collections.emptyList()), null);
//      if (!newPpsIds.isEmpty()) {
//        createdPpsIds.addAll(newPpsIds);
//      }
//    }
//
//    log.info("TRIGGERS: PPSs created by initial auto triggers: " + createdPpsIds.size());
//    log.info("TRIGGERS: PPS ids created by initial auto triggers: " + createdPpsIds);
//
//    return createdPpsIds;
//  }

  public void performTimeBasedAutoTriggers() {

    User cronUser = new User();
    cronUser.setId(SystemSettings.CRON_USER.getId());

    final List<Map<String, Object>> results = sqlCache.query("projectProcessStep.getTimeBasedAutoTriggerPps", null, new ColumnMapRowMapper());

    List<Long> createdPpsIds = new ArrayList<>();

    int counter = 0;

    for(Map<String, Object> result: results) {
      cronUser.setCompanyId(Long.valueOf(result.get("companyId").toString()));
      try {
        log.info(String.format("TRIGGERS: Starting #%s for ppsId: %s", counter++, result.get("ppsId")));
        List<Long> newPpsIds = performAutoTriggerActions(Long.valueOf(result.get("ppsId").toString()), new UserAccountDetails(cronUser, Collections.emptyList()));
        if (!newPpsIds.isEmpty()) {
          createdPpsIds.addAll(newPpsIds);
        }
      } catch (Exception e) {
        // Errors will already be printed to log. Silently swallow exception so we can keep trying other PPSs
      }
    }

    log.info("TRIGGERS: PPS created by time based auto triggers: " + createdPpsIds.size());
    log.info("TRIGGERS: PPS ids created by time based auto triggers: " + createdPpsIds);
  }

  @Transactional
  public List<Long> performAutoTriggerActions(Long ppsId, UserAccountDetails userDetails) {
    return performAutoTriggerActions(ppsId, userDetails, null, null, null, new ArrayList<>());
  }

  @Transactional
  public List<Long> performAutoTriggerActions(Long ppsId, UserAccountDetails userDetails, Long callingProcessStepActionId, Long callingProcessStepId, Long callingPpsId, List<Long> performedActions) {
      // Set the security context so we have user details in the async downline
      securityService.setCurrentUserDetails(userDetails);

      ProjectProcessStep pps = this.getProjectProcessStep(ppsId);

      ArrayList<Long> createdPpsIds = new ArrayList<>();

      boolean actionsWerePerformed = false;

      if (pps.getProcessStepStatusTypeId() == 1) {
          for(ProjectProcessStepAction action: pps.getActions()) {
              final boolean isSameAction = callingProcessStepActionId != null && callingProcessStepActionId.equals(action.getId());
              final boolean isSameProcessStep = callingProcessStepId != null && callingProcessStepId.equals(action.getProcessStepId());
              final boolean isSamePps = callingPpsId != null && callingPpsId.equals(ppsId);
              if (action.getTriggerAutomatically() && !action.getAlreadyTriggered() && !isSameAction && (!isSameProcessStep || !isSamePps) && !performedActions.contains(action.getId())) {
                  try {
                    // Added this to get fresh pps values when looking at each action. Possible performance hit. Might want to lighten the previous getProjectProcessStep call,
                    // which might potentially enable this one to get lighter also
                      ProjectProcessStep updatedPps = this.getProjectProcessStep(ppsId);

                      List<Long> reqIds = action.getProcessStepLogicList().stream()
                          .filter(step -> step.getProcessStepRequirementId() != null)
                          .map(ProcessStepLogic::getProcessStepRequirementId)
                          .collect(Collectors.toList());

                      List<ProjectProcessStepRequirement> reqs = updatedPps.getAutoTriggeredActionRequirements().stream()
                          .filter(r -> reqIds.contains(r.getId()))
                          .collect(Collectors.toList());
                    ProjectProcessStepAction actionResult = this.canPerformAction(action, updatedPps, reqs);
                      if (actionResult.getCanPerform()) {
                          performedActions.add(action.getId());
                          List<Long> newPpsIds = this.performAction(action, updatedPps, performedActions);
                          if (!newPpsIds.isEmpty()) {
                            createdPpsIds.addAll(newPpsIds);
                          }
                          actionsWerePerformed = true;
                      }
                  } catch (StackOverflowError e) {
                    final String errMessage = String.format("PPS: INFINITE LOOP DETECTED - Unable to AUTO trigger action ID: %s, PPS ID: %s *** %s",  action.getId(), ppsId, e.getMessage());
                    log.error(errMessage);
                    throw new RuntimeException(errMessage);
                  } catch (Exception e) {
                    final String errMessage = String.format("PPS: Unable to AUTO trigger action ID: %s, PPS ID: %s *** %s",  action.getId(), ppsId, e.getMessage());
                    log.error(errMessage);
                    throw new RuntimeException(errMessage);
                  }
              }
          }

          if (actionsWerePerformed) {
            List<Long> cfgaIds = customFieldValueService.getIdsByPPSId(ppsId);
            if (!cfgaIds.isEmpty()) {
              List<Long> ppsIds = getIdsForAutoTriggerByCfgaIds(pps.getProjectId(), null, cfgaIds);
              for (Long checkingPpsId : ppsIds) {
                // Don't re-check the ppsId we are in currently
                if (!checkingPpsId.equals(ppsId))  {
                  performAutoTriggerActions(checkingPpsId, securityService.getCurrentUserDetails(), null, pps.getProcessStepId(), ppsId, performedActions);
                }
              }
            }
          }
      }

      return createdPpsIds;
  }

  //putting this here due to circular reference issue i dont want to solve. yes it is weird i know
  public Optional<ProjectProcessStepEvent> getPpseEventWithStatus(Long ppseId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ppseId", ppseId);

    Optional<ProjectProcessStepEvent> result = sqlCache.get("projectProcessStepEvent.getWithStatus", params, ProjectProcessStepEvent.class);
    return result;
  }

  @Transactional
  public List<Long> performAction(ProcessStepAction action, ProjectProcessStep pps, List<Long> performedActions) {
    /*
     * transaction all queries so current state is kept on any errors
     * Performance will be key here as it will be hit a lot and business logic will grow
     */

    var runStatusTriggers = false;
    var childFunctionsRan = false;

    User user = securityService.getCurrentUser();
    //update process step status if needed
    if (action.getCompanyProcessStepStatusTypeId() != null) {
      this.setStatus(pps.getProjectProcessStepId(), action.getProcessStepStatusTypeId(), action.getCompanyProcessStepStatusTypeId(), null);
      runStatusTriggers = true;
    }

    //remove process step owner if needed (BR request, dont hate)
    if (action.getRemoveProcessStepOwner()) {
      this.removeOwner(pps.getProjectProcessStepId());
    }

    //update project status if needed
    if (action.getCompanyProjectStatusTypeId() != null) {
      this.setProjectStatus(pps.getProjectId(), action.getCompanyProjectStatusTypeId());
    }

    childFunctionsRan = performChildFunctions(action.getId(), pps.getProjectProcessStepId(), pps.getProcessStepId(), pps.getProjectId());

    ArrayList<Map<String, Object>> createdPps = new ArrayList<>();

    for (ProcessStepActionChildProcess childStep: action.getProcessStepActionChildProcesses()) {
      Long ppsId = this.insertProjectProcessStep(pps.getProjectId(), childStep.getProcessStepId(), null, pps.getProjectProcessStepId(), childStep.getInitialCompanyProcessStepStatusTypeId(), childStep.getExistingCompanyProcessStepStatusTypeId());
      createdPps.add(Map.of("ppsId", ppsId, "shouldAutoTrigger", childStep.getAutoTriggerActionCount() > 0));
    }

    sqlCache.update("projectProcessStep.insertPerformedAction", Map.of("ppsId", pps.getProjectProcessStepId(),
      "psaId", action.getId(), "autoTriggered", action.getTriggerAutomatically(), "createdById", user.trueUserId(), "allowMultipleUses", action.getMultipleUses()));

    //run autotriggers on parent pps if any functions were performed
    if (childFunctionsRan) {
      this.performAutoTriggerActions(pps.getProjectProcessStepId(), securityService.getCurrentUserDetails(), action.getId(), pps.getProcessStepId(), pps.getProjectProcessStepId(), performedActions);
    }

    //run autotriggers for all created child PPSs which have any auto trigger actions
    createdPps.stream()
      .filter(childStep -> Boolean.parseBoolean(childStep.get("shouldAutoTrigger").toString()))
      .forEach(childStep -> this.performAutoTriggerActions(Long.parseLong(childStep.get("ppsId").toString()), securityService.getCurrentUserDetails(), action.getId(), pps.getProcessStepId(), pps.getProjectProcessStepId(), performedActions));

    //run autotriggers for actions which use the new child PPSs status
    if (!createdPps.isEmpty()) {
      List<Long> ids = createdPps.stream().map(step -> Long.parseLong(step.get("ppsId").toString())).toList();
      List<ProjectProcessStep> steps = sqlCache.query("projectProcessStep.getUsingStatusByPpsIds", Map.of("projectProcessStepIds", ids), ProjectProcessStep.class);
      for(ProjectProcessStep step : steps) {
        //only run if the referring PPS is active, not the parent PPS, and not a new child PPS (since we already ran through those autotriggers)
        if(step.getProcessStepStatusTypeId() == 1 && !Objects.equals(pps.getProjectProcessStepId(), step.getProjectProcessStepId()) && !ids.contains(step.getProjectProcessStepId())) {
          performAutoTriggerActions(step.getProjectProcessStepId(), securityService.getCurrentUserDetails(), action.getId(), pps.getProcessStepId(), pps.getProjectProcessStepId(), performedActions);
        }
      }
    }

    // If there was a status change by updating the parent PPS
    if (runStatusTriggers) {
      //run auto triggers for PPSs which use the new PPS status
      List<ProjectProcessStep> steps = sqlCache.query("projectProcessStep.getUsingStatusByPpsIds", Map.of("projectProcessStepIds", List.of(pps.getProjectProcessStepId())), ProjectProcessStep.class);
      for(ProjectProcessStep step : steps) {
        //only run if the referring PPS is active and not the parent PPS
        if(step.getProcessStepStatusTypeId() == 1 && !Objects.equals(pps.getProjectProcessStepId(), step.getProjectProcessStepId())) {
          performAutoTriggerActions(step.getProjectProcessStepId(), securityService.getCurrentUserDetails(), action.getId(), pps.getProcessStepId(), pps.getProjectProcessStepId(), performedActions);
        }
      }
    }

    return createdPps.stream().map(step -> Long.parseLong(step.get("ppsId").toString())).toList();
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
        final String errMessage = String.format("PPS: Exception while checking action requirements. PPS ID: %s", r.getId());
        throw new RuntimeException(errMessage + " *** " + e.getMessage());
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
      action.setCanPerform(parser.parseExpression(logicString.toString()).getValue(Boolean.class));
    } else {
      action.setCanPerform(requirements.stream().allMatch(ProcessStepRequirement::getFulfilled));
    }

    return action;
  }

  public boolean isRequirementMet(ProjectProcessStepRequirement r, Long ppsId) throws Exception {
    return isRequirementMet(r, ppsId, null);
  }

  // It's assumed for date data types that it's always a data_type_requirement and never a literal comparison of values
  public boolean isRequirementMet(ProjectProcessStepRequirement r, Long ppsId, Long ppseId) throws Exception {

    boolean requirementMet = false;

    //2 = function
    if (r.getProcessStepRequirementTypeId() == 2) {
      try {
        String params = String.join(", ", prepareFunctionParams(r.getCompanyFunctionParams(), r.getProjectId(), r.getProcessStepId(), ppsId, ppseId));
        String query = String.format("select * from %s(%s)", r.getFunctionName(), params);
        Optional<Object> returnValue = sqlCache.getBySql(query, null, new SingleColumnRowMapper<>(Object.class));
        requirementMet = calculateFunctionRequirement(returnValue.orElse(null), r);
      } catch (Exception e) {
        throw new RuntimeException(String.format("Unable to calculate function requirement, PPS requirement ID: %s, PPS ID: %s *** %s", r.getId(), ppsId, e.getMessage()));
      }
    } else if(r.getProcessStepRequirementTypeId().equals(com.albatross.api.v1.flow.enums.ProcessStepRequirementType.PROCESS_STEP_STATUS.id) || r.getProcessStepRequirementTypeId().equals(com.albatross.api.v1.flow.enums.ProcessStepRequirementType.PROCESS_STEP_STATUS_CATEGORY.id)) {
      // 7 = check process step status type from reference step
      // 8 = check process step status category type from reference step
      requirementMet = calculateStatusRequirement(r, ppsId, false, r.getProcessStepRequirementTypeId());
    } else if(r.getProcessStepRequirementTypeId().equals(com.albatross.api.v1.flow.enums.ProcessStepRequirementType.PROJECT_STATUS.id) || r.getProcessStepRequirementTypeId().equals(com.albatross.api.v1.flow.enums.ProcessStepRequirementType.PROJECT_STATUS_CATEGORY.id)) {
      // 9 = check project status type
      // 8 = check project status category type
      requirementMet = calculateStatusRequirement(r, ppsId, true, r.getProcessStepRequirementTypeId());
    } else if (r.getProcessStepRequirementTypeId().equals(com.albatross.api.v1.flow.enums.ProcessStepRequirementType.EVENT_STATUS.id)) {
      //11 = company event status check
      requirementMet = calculateEventStatusRequirement(r, ppseId, r.getProcessStepRequirementTypeId());
    } else {
//      go through requirement.data_type_id to select the correct value prop. Then use the operation type to dun the correct comparison

        try {
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
            case 13:
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
              break;
            default:
              throw new RuntimeException("Unable to determine requirement data type");
          }
        } catch (Exception e) {
          throw new RuntimeException(String.format("Unable to check requirement, req ID: %s, PPS ID: %s *** %s", r.getId(), ppsId, e.getMessage()));
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

  public boolean calculateEventStatusRequirement(ProjectProcessStepRequirement requirement, Long ppseId, Long requirementTypeId) {
    boolean passed = false;

    Optional<ProjectProcessStepEvent> ppseWithStatus = getPpseEventWithStatus(ppseId);
    if(ppseWithStatus.isPresent()) {
      // check if the status is in one of the statuses
      //use this one vv when they change to want event category too
      //int idToCheck = requirementTypeId.equals(com.albatross.api.v1.flow.enums.ProcessStepRequirementType.EVENT_STATUS.id) ? ppseWithStatus.get().getCompanyEventStatusTypeId().intValue() : ppseWithStatus.get().getEventStatusTypeId().intValue();
      int idToCheck = ppseWithStatus.get().getCompanyEventStatusTypeId().intValue();
      passed = requirement.getListOfValueIds().contains(idToCheck);
    }

    return passed;
  }

  public boolean calculateStatusRequirement(ProjectProcessStepRequirement requirement, Long projectProcessStepId, Boolean isProject, Long requirementTypeId) {
    boolean passed = false;

    if(isProject) {
      //if there is a pps then check the project status from that
      Optional<Project> projectWithStatus = projectService.getStatus(requirement.getProjectId());
      if(projectWithStatus.isPresent()) {
        // check if the status is in one of the statuses
        int idToCheck = requirementTypeId.equals(com.albatross.api.v1.flow.enums.ProcessStepRequirementType.PROJECT_STATUS.id) ? projectWithStatus.get().getCompanyProjectStatusTypeId().intValue() : projectWithStatus.get().getProjectStatusTypeId().intValue();
        passed = requirement.getListOfValueIds().contains(idToCheck);
      } else {
        //
        passed = !requirement.getFailIfNoReferenceStepFound();
      }
    } else {
      //check process step status here
      //get the primary pps of the reference_process_step_id type
      HashMap<String, Object> params = new HashMap<>();
      params.put("referenceProcessStepId", requirement.getReferenceProcessStepId());
      params.put("ppsId", projectProcessStepId);
//      params.put("selectedCompanyStatusIds", requirement.getListOfValueIds());

      Optional<ProjectProcessStep> projectProcessStep = sqlCache.get("projectProcessStep.getPrimaryByReferenceProcessStepAndStatus", params, ProjectProcessStep.class);

      //if we found a primary pss of that type
      if(projectProcessStep.isPresent()) {
        // check if the status is in one of the statuses
        int idToCheck = requirementTypeId.equals(com.albatross.api.v1.flow.enums.ProcessStepRequirementType.PROCESS_STEP_STATUS.id) ? projectProcessStep.get().getCompanyProcessStepStatusTypeId().intValue() : projectProcessStep.get().getProcessStepStatusTypeId().intValue();
        passed = requirement.getListOfValueIds().contains(idToCheck);
      } else {
        //if we didn't find one, check the "failIfNoReferenceStepFound" value
        passed = !requirement.getFailIfNoReferenceStepFound();
      }
    }
    return passed;
  }

  public boolean calculateFunctionRequirement(Object functionResult, ProjectProcessStepRequirement r) throws RuntimeException {
    boolean passed = false;
    switch (r.getDataTypeId().intValue()) {
      case 1:
        // @TODO: Duped from the button logic, potentially combine
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDateTime dateFunctionResult = (functionResult !=  null) ? LocalDate.parse(functionResult.toString(), dateFormatter).atStartOfDay() : null;
        LocalDateTime nowForDate = LocalDateTime.now();
        String secondaryDateValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

        ZonedDateTime zonedDateFunctionResult = (dateFunctionResult != null) ? dateFunctionResult.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of(r.getTimeZone())) : null;
        ZonedDateTime zonedDateNow = nowForDate.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of(r.getTimeZone()));

        try {
          switch (r.getDataTypeRequirementId().intValue()) {
            case 1:
              Assert.notNull(secondaryDateValue, "Unable to determine secondary value");
              passed = compareDates(dateFunctionResult, zonedDateNow.minusDays(Long.parseLong(secondaryDateValue)), r.getOperatorTypeId());
              break;
            case 2:
              Assert.notNull(secondaryDateValue, "Unable to determine secondary value");
              passed = compareDates(dateFunctionResult, zonedDateNow.plusDays(Long.parseLong(secondaryDateValue)), r.getOperatorTypeId());
              break;
            case 3:
              passed = compareDates(dateFunctionResult, zonedDateNow, r.getOperatorTypeId());
              break;
            case 4:
              passed = compareNullDate(dateFunctionResult, r.getOperatorTypeId());
              break;
            case 5:
              passed = compareNonNullDate(dateFunctionResult, r.getOperatorTypeId());
              break;
          }
        } catch (Exception e) {
          throw new RuntimeException(String.format("PPS: Error comparing date requirement to function result. Requirement ID: %s, Data Type Requirement ID: %s *** %s", r.getId(), r.getDataTypeRequirementId(), e.getMessage()));
        }
        break;
      case 2:
        // @TODO: Duped from the button logic, potentially combine
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.n");
        LocalDateTime timestampFunctionResult = (functionResult !=  null) ? LocalDateTime.parse(functionResult.toString(), dateTimeFormatter).withMinute(0).withSecond(0).withNano(0) : null;
        LocalDateTime nowForTimestamp =  LocalDateTime.now().withMinute(0).withSecond(0).withNano(0);
        String secondaryTimestampValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

        ZonedDateTime zoneTimestampFunctionResult = (timestampFunctionResult != null) ? timestampFunctionResult.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of(r.getTimeZone())) : null;
        ZonedDateTime zonedTimestampNow = nowForTimestamp.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of(r.getTimeZone()));

        try {
          switch (r.getDataTypeRequirementId().intValue()) {
            case 6:
              Assert.notNull(secondaryTimestampValue, "Unable to determine secondary value");
              passed = compareDates(timestampFunctionResult, zonedTimestampNow.minusDays(Long.parseLong(secondaryTimestampValue)), r.getOperatorTypeId());
              break;
            case 7:
              Assert.notNull(secondaryTimestampValue, "Unable to determine secondary value");
              passed = compareDates(timestampFunctionResult, zonedTimestampNow.plusDays(Long.parseLong(secondaryTimestampValue)), r.getOperatorTypeId());
              break;
            case 8:
              passed = compareDates(timestampFunctionResult, zonedTimestampNow, r.getOperatorTypeId());
              break;
            case 9:
              Assert.notNull(secondaryTimestampValue, "Unable to determine secondary value");
              passed = compareDateTimes(zoneTimestampFunctionResult, zonedTimestampNow.minusHours(Long.parseLong(secondaryTimestampValue)), r.getOperatorTypeId());
              break;
            case 10:
              Assert.notNull(secondaryTimestampValue, "Unable to determine secondary value");
              passed = compareDateTimes(zoneTimestampFunctionResult, zonedTimestampNow.plusHours(Long.parseLong(secondaryTimestampValue)), r.getOperatorTypeId());
              break;
            case 11:
              passed = compareDateTimes(zoneTimestampFunctionResult, zonedTimestampNow, r.getOperatorTypeId());
              break;
            case 12:
              passed = compareNullDateTime(zoneTimestampFunctionResult, r.getOperatorTypeId());
              break;
            case 13:
              passed = compareNonNullDateTime(zoneTimestampFunctionResult, r.getOperatorTypeId());
              break;
          }
        } catch (Exception e) {
          throw new RuntimeException(String.format("PPS: Error comparing timestamp requirement to function result. Requirement ID: %s, Data Type Requirement ID: %s *** %s", r.getId(), r.getDataTypeRequirementId(), e.getMessage()));
        }
        break;
      case 3:
        // @TODO: Duped from the button logic, potentially combine
        Boolean booleanFunctionResult = (functionResult == null) ? null : Boolean.valueOf(functionResult.toString());

        try {
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
        } catch (Exception e) {
          throw new RuntimeException(String.format("PPS: Error comparing bool requirement to function result. Requirement ID: %s, Data Type Requirement ID: %s *** %s", r.getId(), r.getDataTypeRequirementId(), e.getMessage()));
        }
        break;
      case 4:
        // @TODO: Duped from the button logic, potentially combine
        Double numericFunctionResult = (functionResult == null) ? null : new BigDecimal(functionResult.toString()).setScale(2, RoundingMode.DOWN).doubleValue();

        try {
          switch (r.getDataTypeRequirementId().intValue()) {
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
        } catch (Exception e) {
          throw new RuntimeException(String.format("PPS: Error comparing numeric requirement to function result. Requirement ID: %s, Data Type Requirement ID: %s *** %s", r.getId(), r.getDataTypeRequirementId(), e.getMessage()));
        }
        break;
      case 5:
        // @TODO: Duped from the button logic, potentially combine
        String stringFunctionResult = (functionResult != null) ? functionResult.toString() : null;
        // An empty string and null are treated as the same value during text comparison

        try {
          switch (r.getDataTypeRequirementId().intValue()) {
            case 18: //null for text
            case 30: //null for rich text
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
            case 19:  //not null for text
            case 31:  //not null for rich text
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
        } catch (Exception e) {
          throw new RuntimeException(String.format("PPS: Error comparing text requirement to function result. Requirement ID: %s, Data Type Requirement ID: %s *** %s", r.getId(), r.getDataTypeRequirementId(), e.getMessage()));
        }
        break;
      case 6:
      case 9:
        Long intFunctionResult = (functionResult != null) ? Long.valueOf(functionResult.toString()) : null;
        if (r.getDataTypeRequirementId() == null) {
          try {
            Long reqValue = Long.parseLong(r.getRequirementValue());
            passed = compareInt(intFunctionResult, reqValue, r.getOperatorTypeId());
          } catch (Exception e) {
            throw new RuntimeException(String.format("PPS: Error parsing int requirement to function result. Requirement ID: %s *** %s", r.getId(), e.getMessage()));
          }
        } else {
          try {
            switch (r.getDataTypeRequirementId().intValue()) {
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
          } catch (Exception e) {
            throw new RuntimeException(String.format("PPS: Error comparing int/system list requirement to function result. Requirement ID: %s, Data Type Requirement ID: %s *** %s", r.getId(), r.getDataTypeRequirementId(), e.getMessage()));
          }
        }
        break;
      case 7:
        break;
      default:

    }
    return passed;
  }

    public Boolean performChildFunctions(Long actionId, Long ppsId, Long processStepId, Long projectId) {
        var shouldRunAutoTriggers = false;
        List<ProcessStepActionChildFunction> childFunctions = processStepActionService.getChildFunctionsWithParamValues(actionId, ppsId);
        childFunctions.forEach(childFunction -> {
          try {
            if (childFunction.getRunInBackend()) {
              User user = securityService.getCurrentUser();

              final String originalFuncName = childFunction.getFunctionName();
              final int dot = originalFuncName.indexOf('.');
              final String functionAbbreviation = originalFuncName.substring(0, dot);
              final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));

              Map<String, Object> systemValues = new HashMap<>();
              systemValues.put("processStepId", processStepId);
              systemValues.put("ppsId", ppsId);
              systemValues.put("projectId", projectId);
              systemValues.put("userId", user.getId());
              systemValues.put("companyId", user.getCompanyId());

              if (functionAbbreviation.equals("brs")) {
                var functionClass = new BrsProcessStepActionFunctionService(sqlCache, goodleapService, auroraService, marketoService, listOfValueService);
                Method method = BrsProcessStepActionFunctionService.class.getMethod(functionName, ProcessStepActionChildFunction.class, Map.class);
                method.invoke(functionClass, childFunction, systemValues);
              } else {
                // @TODO: Add company IDs here during onboarding
              }
            } else {
              String params = String.join(", ", prepareFunctionParams(childFunction.getCompanyFunctionParams(), childFunction.getProjectId(), processStepId, ppsId, null));
              String query = String.format("select * from %s(%s)", childFunction.getFunctionName(), params);
              sqlCache.getBySql(query, null, new SingleColumnRowMapper<>(Object.class));
            }
          } catch (InvocationTargetException e) {
            throw new RuntimeException(String.format("PPS: Unable to run child action function. CFA ID: %s, action ID: %s, PPS ID: %s *** %s", childFunction.getId(), actionId, ppsId, e.getCause().getMessage()));
          } catch (Exception e) {
            throw new RuntimeException(String.format("PPS: Unable to run child action function. CFA ID: %s, action ID: %s, PPS ID: %s *** %s", childFunction.getId(), actionId, ppsId, e.getMessage()));
          }
        });

        if (!childFunctions.isEmpty()) {
          shouldRunAutoTriggers = true;
        }

        return shouldRunAutoTriggers;
    }

  public String[] prepareFunctionParams(List<CompanyFunctionParam> functionParams, Long projectId, Long processStepId, Long ppsId, Long ppsEventId) throws Exception {
    Map<Long, String> params = new TreeMap<>();

    functionParams.forEach(param -> {
      try {
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
              case 5:
                systemValue = ppsEventId;
                break;
              default:
                throw new RuntimeException(String.format("Unable to determine param type, CF param ID: %s", param.getId()));
            }
            params.put(param.getDisplayOrder(), systemValue != null ? systemValue.toString() : null);
            break;
          case 2:
            params.put(param.getDisplayOrder(), getTypedDynamicValue(param).toString());
            break;
          case 3:
            Object paramValue = getParamValueByDataType(param);
            params.put(param.getDisplayOrder(), (paramValue != null) ? paramValue.toString() : null);
            break;
          default:
            throw new RuntimeException(String.format("Unable to determine param type, CF param ID: %s", param.getId()));
        }
      } catch (Exception e) {
        throw new RuntimeException(String.format("Unable to prepare params, CF param ID: %s, CF ID: %s *** %s", param.getId(), param.getCompanyFunctionId(), e.getMessage()));
      }
    });

    return params.values().toArray(String[]::new);
  }

  public Object getTypedDynamicValue(CompanyFunctionParam param) throws RuntimeException {

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
      case 13:
        typedValue = "'" + startingValue + "'";
        break;
      case 6:
        typedValue = Long.parseLong(startingValue);
        break;
      default:
        throw new RuntimeException(String.format("Unable to determine typed param dynamic value, CF param ID: %s", param.getId()));
    }
  } catch (Exception e) {
    throw new RuntimeException(String.format("Unable to get typed dynamic value, CF param ID: %s, CF ID: %s *** %s", param.getId(), param.getCompanyFunctionId(), e.getMessage()));
  }

    return typedValue;
  }

  public Object getParamValueByDataType(CompanyFunctionParam param) throws RuntimeException {

    Object paramValue = null;

    try {
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
        case 13:
          paramValue = param.getTextValue();
          break;
        case 6:
          paramValue = param.getIntValue();
          break;
        case 7:
          paramValue = param.getIntArrayValue();
          break;
        default:
          throw new RuntimeException(String.format("Unable to determine param value by data type, CF param ID: %s", param.getId()));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to get param value by data type, CF param ID: %s, CF ID: %s *** %s", param.getId(), param.getCompanyFunctionId(), e.getMessage()));
    }

    return paramValue;
  }

  public boolean calculateMultiselectRequirement(ProjectProcessStepRequirement r) throws RuntimeException {

    List<Integer> fieldValue = r.getIntArrayValue();

    boolean passed = false;

    try {
      if (r.getDataTypeRequirementId() == null) {
        List<Integer> reqValue = r.getListOfValueIds();
        passed = compareMultiselect(fieldValue, reqValue, r.getOperatorTypeId());
      } else {
        switch (r.getDataTypeRequirementId().intValue()) {
          case 22:
            passed = fieldValue.isEmpty();
            break;
          case 23:
            passed = !fieldValue.isEmpty();
            break;
          default:
            throw new RuntimeException(String.format("Unable to parse multiselect data type, operator ID: %s", r.getOperatorTypeId()));
        }

        if (r.getOperatorTypeId() == 2) {
          passed = !passed;
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to calculate multiselect requirement, PS requirement ID: %s *** %s", r.getId(), e.getMessage()));
    }

    return passed;
  }

  public boolean compareMultiselect(List<Integer> numbers, List<Integer> compareNumbers, Long operatorTypeId) throws Exception {

    boolean passed = false;
    try {
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
          throw new Exception(String.format("Unable to parse multiselect data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare multiselect values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }
    return passed;
  }

  public boolean caclulateDropdownRequirement(ProjectProcessStepRequirement r) throws Exception {

    Long fieldValue = r.getIntValue();

    boolean passed = false;

    try {
      if (r.getDataTypeRequirementId() == null) {
        Long reqValue = r.getListOfValueId();
        passed = compareDropdown(fieldValue, reqValue, r.getOperatorTypeId());
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
                throw new Exception(String.format("Unable to parse int data type, operator ID: %s", r.getOperatorTypeId()));
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
            throw new Exception(String.format("Unable to parse dropdown data type, operator ID: %s", r.getOperatorTypeId()));
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to calculate dropdown requirement, PS requirement ID: %s *** %s", r.getId(), e.getMessage()));
    }

    return passed;
  }

  public boolean compareDropdown(Long number, Long compareNumber, Long operatorTypeId) throws Exception {

    boolean passed = false;

    try {
      switch (operatorTypeId.intValue()) {
        case 1:
          passed = Objects.equals(number, compareNumber);
          break;
        case 2:
          passed = !Objects.equals(number, compareNumber);
          break;
        default:
          throw new Exception(String.format("Unable to parse dropdown data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare dropdown values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean calculateIntRequirement(ProjectProcessStepRequirement r) throws RuntimeException {

    Long fieldValue = r.getIntValue();
    boolean passed = false;

    try {
      if (r.getDataTypeRequirementId() == null) {
        Long reqValue = Long.parseLong(r.getRequirementValue());
        passed = compareInt(fieldValue, reqValue, r.getOperatorTypeId());
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
                throw new Exception(String.format("Unable to parse int data type, operator ID: %s", r.getOperatorTypeId()));
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
                throw new Exception(String.format("Unable to parse int data type, operator ID: %s", r.getOperatorTypeId()));
            }
            break;
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to calculate int requirement, PS requirement ID: %s *** %s", r.getId(), e.getMessage()));
    }

    return passed;
  }

  public boolean compareInt(Long number, Long compareNumber, Long operatorTypeId) throws RuntimeException {

    boolean passed = false;

    try {
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
          throw new RuntimeException(String.format("Unable to parse int data type, operator of ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare int values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean calculateTextRequirement(ProjectProcessStepRequirement r) throws RuntimeException {

    String fieldValue = r.getTextValue();

    boolean passed = false;

    try {
      if (r.getDataTypeRequirementId() == null) {
        String reqValue = r.getRequirementValue();
        passed = compareText(fieldValue, reqValue, r.getOperatorTypeId());
      } else {
        // An empty string and null are treated as the same value during text comparison
        switch (r.getDataTypeRequirementId().intValue()) {
          case 18: //null for text
          case 30: //null for rich text
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
                throw new Exception(String.format("Unable to parse text data type, operator ID: %s", r.getOperatorTypeId()));
            }
            break;
          case 19:  //not null for text
          case 31:  //not null for rich text
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
                throw new Exception(String.format("Unable to parse text data type, operator ID: %s", r.getOperatorTypeId()));
            }
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to calculate text requirement, PS requirement ID: %s *** %s", r.getId(), e.getMessage()));
    }

    return passed;
  }

  public boolean compareText(String text, String compareText, Long operatorTypeId) throws RuntimeException {

    boolean passed = false;

    // Treat empty strings and null the same
    text = (text != null) ? text.trim().toLowerCase() : "";
    compareText = (compareText != null) ? compareText.trim().toLowerCase() : "";

    try {
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
          throw new RuntimeException(String.format("Unable to parse text data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare text values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean calculateNumericRequirement(ProjectProcessStepRequirement r) throws Exception {

    Double fieldValue = (r.getNumericValue() == null) ? null : r.getNumericValue().setScale(2, RoundingMode.DOWN).doubleValue();

    boolean passed = false;

    try {
      if (r.getDataTypeRequirementId() == null) {
        Double reqValue = new BigDecimal(r.getRequirementValue()).setScale(2, RoundingMode.DOWN).doubleValue();
        passed = compareNumeric(fieldValue, reqValue, r.getOperatorTypeId());
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
                throw new Exception(String.format("Unable to parse numeric data type, operator ID: %s", r.getOperatorTypeId()));
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
                throw new Exception(String.format("Unable to parse numeric data type, operator ID: %s", r.getOperatorTypeId()));
            }
            break;
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to calculate numeric requirement, PS requirement ID: %s *** %s", r.getId(), e.getMessage()));
    }

    return passed;
  }

  public boolean compareNumeric(Double number, Double compareNumber, Long operatorTypeId) throws Exception {

    boolean passed = false;

    try {
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
          throw new Exception(String.format("Unable to parse numeric data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare numeric values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean calculateBooleanRequirement(ProjectProcessStepRequirement r) throws Exception {

    Boolean fieldValue = r.getBooleanValue();

    boolean passed = false;

    try {
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
              throw new Exception(String.format("Unable to parse bool data type, operator ID: %s", r.getOperatorTypeId()));
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
              throw new Exception(String.format("Unable to parse bool data type, operator ID: %s", r.getOperatorTypeId()));
          }
          break;
        default:
          throw new Exception(String.format("Unable to parse bool data type, operator ID: %s", r.getOperatorTypeId()));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to calculate bool requirement, PS requirement ID: %s *** %s", r.getId(), e.getMessage()));
    }

    return passed;
  }

  public boolean calculateTimestampRequirement(ProjectProcessStepRequirement r) throws Exception {

    // Fallback to mountain time if there isn't a project specific timezone
    if (r.getTimeZone() == null) {
      r.setTimeZone("America/Denver");
    }

    LocalDateTime fieldValue = (r.getTimestampValue() != null) ? r.getTimestampValue().toLocalDateTime().withMinute(0).withSecond(0).withNano(0) : null;
    LocalDateTime now = LocalDateTime.ofInstant(Instant.now(), ZoneId.of("UTC")).withMinute(0).withSecond(0).withNano(0);
    String secondaryValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

    ZonedDateTime zonedFieldValue = (fieldValue != null) ? fieldValue.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of(r.getTimeZone())) : null;
    ZonedDateTime zonedNow = now.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of(r.getTimeZone()));

    boolean passed = false;

    try {
      if (null == r.getDataTypeRequirementId()) {
        ZonedDateTime zonedReqValue = LocalDateTime.parse(r.getRequirementValue()).atZone(ZoneId.of(r.getTimeZone()));
        passed = compareDateTimes(zonedFieldValue, zonedReqValue, r.getOperatorTypeId());
      } else {
        switch (r.getDataTypeRequirementId().intValue()) {
          case 6:
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates((fieldValue != null) ? zonedFieldValue.toLocalDateTime() : null, zonedNow.minusDays(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
            break;
          case 7:
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates((fieldValue != null) ? zonedFieldValue.toLocalDateTime() : null, zonedNow.plusDays(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
            break;
          case 8:
            passed = compareDates((fieldValue != null) ? zonedFieldValue.toLocalDateTime() : null, zonedNow, r.getOperatorTypeId());
            break;
          case 9:
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDateTimes(zonedFieldValue, zonedNow.minusHours(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
            break;
          case 10:
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDateTimes(zonedFieldValue, zonedNow.plusHours(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
            break;
          case 11:
            passed = compareDateTimes(zonedFieldValue, zonedNow, r.getOperatorTypeId());
            break;
          case 12:
            passed = compareNullDateTime(zonedFieldValue, r.getOperatorTypeId());
            break;
          case 13:
            passed = compareNonNullDateTime(zonedFieldValue, r.getOperatorTypeId());
            break;
          default:
            throw new Exception(String.format("Unable to parse timestamp data type, operator ID: %s", r.getOperatorTypeId()));
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to calculate timestamp requirement, PS requirement ID: %s *** %s", r.getId(), e.getMessage()));
    }

    return passed;
  }

  public boolean compareNullDateTime(ZonedDateTime date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    try {
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
          throw new Exception(String.format("Unable to parse null timestamp data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare null timestamp values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean compareNonNullDateTime(ZonedDateTime date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    try {
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
          throw new Exception(String.format("Unable to parse non null timestamp data type, operator of ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare non null timestamp values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean compareDateTimes(ZonedDateTime date, ZonedDateTime compareDate, Long operatorTypeId) throws RuntimeException {

    boolean passed = false;

    try {
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
          throw new Exception(String.format("Unable to parse timestamp data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare timestamp values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean calculateDateRequirement(ProjectProcessStepRequirement r) throws Exception {

    // Fallback to mountain time if there isn't a project specific timezone
    if (r.getTimeZone() == null) {
      r.setTimeZone("America/Denver");
    }

    LocalDateTime fieldValue = (r.getDateValue() !=  null) ? r.getDateValue().toLocalDateTime() : null;
    LocalDateTime now = LocalDateTime.ofInstant(Instant.now(), ZoneId.of("UTC")).withMinute(0).withSecond(0).withNano(0);
    String secondaryValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

    ZonedDateTime zonedNow = now.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of(r.getTimeZone()));

    boolean passed = false;

    try {
      if (null == r.getDataTypeRequirementId()) {
        // do direct literal operator compare
        // try to make a date out of the requirement value
        ZonedDateTime zonedReqValue = LocalDate.parse(r.getRequirementValue()).atStartOfDay().atZone(ZoneId.of(r.getTimeZone()));
        passed = compareDates(fieldValue, zonedReqValue, r.getOperatorTypeId());
      } else {
        switch (r.getDataTypeRequirementId().intValue()) {
          case 1:
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue, zonedNow.minusDays(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
            break;
          case 2:
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue, zonedNow.plusDays(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
            break;
          case 3:
            passed = compareDates(fieldValue, zonedNow, r.getOperatorTypeId());
            break;
          case 4:
            passed = compareNullDate(fieldValue, r.getOperatorTypeId());
            break;
          case 5:
            passed = compareNonNullDate(fieldValue, r.getOperatorTypeId());
            break;
          default:
            throw new Exception(String.format("Unable to parse date data type, operator ID: %s", r.getOperatorTypeId()));
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to calculate date requirement, PS requirement ID: %s *** %s", r.getId(), e.getMessage()));
    }

    return passed;
  }

  public boolean compareNonNullDate(LocalDateTime date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    try {
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
          throw new Exception(String.format("Unable to parse non null date data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare non null date values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean compareNullDate(LocalDateTime date, Long operatorTypeId) throws RuntimeException {

    boolean passed = false;

    try {
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
          throw new RuntimeException(String.format("Unable to parse null date data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare null date values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public boolean compareDates(LocalDateTime date, ZonedDateTime compareDate, Long operatorTypeId) throws RuntimeException {

    if (date != null) {
      date = date.withHour(0).withMinute(0).withSecond(0).withNano(0);
    }

    if (compareDate != null) {
      compareDate = compareDate.withHour(0).withMinute(0).withSecond(0).withNano(0);
    }

    boolean passed = false;

    try {
      switch (operatorTypeId.intValue()) {
        case 1:
          passed = Objects.equals(date, compareDate.toLocalDateTime());
          break;
        case 2:
          passed = !Objects.equals(date, compareDate.toLocalDateTime());
          break;
        case 3:
          passed = date != null && date.isAfter(compareDate.toLocalDateTime());
          break;
        case 4:
          passed = date != null && date.isBefore(compareDate.toLocalDateTime());
          break;
        default:
          throw new RuntimeException(String.format("Unable to parse date data type, operator ID: %s", operatorTypeId));
      }
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to compare date values, operator ID: %s *** %s", operatorTypeId, e.getMessage()));
    }

    return passed;
  }

  public Optional<String> getInstallationScopeOfWork(Long projectId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("companyId", user.getCompanyId());
    return
      sqlCache.get(
        "projectProcessStep.getProjectInstallationScopeOfWork",
        params,
        new SingleColumnRowMapper<>(String.class));
  }
}
