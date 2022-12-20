package com.albatross.api.v1.flow.services;

import com.albatross.api.aurora.AuroraProxy;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.BrsProcessStepActionFunctionService;
import com.albatross.api.v1.company.blueraven.services.GoodleapService;
import com.albatross.api.v1.company.blueraven.services.MarketoService;
import com.albatross.api.v1.flow.controllers.ProjectProcessStepEventController;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.ProcessStepStatusType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.processStep.*;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStep;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepRequirement;
import com.albatross.api.v1.flow.queries.AttachmentQuery;
import com.albatross.api.v1.flow.queries.ProjectProcessStepEventQuery;
import com.albatross.api.v1.flow.queries.ProjectProcessStepQuery;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProjectProcessStepEventService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldValueService customFieldValueService;
  private final ProjectProcessStepService projectProcessStepService;

  private final PubSubService pubSubService;
  private final ProcessStepEventService processStepEventService;
  private final ProjectProcessStepRequirementService projectProcessStepRequirementService;
  private final AttachmentService attachmentService;
  private final AmazonS3 s3;
  private final ObjectMapper om;
  private final GoodleapService goodleapService;
  private final AuroraProxy auroraService;

  private final MarketoService marketoService;
  private final ListOfValueService listOfValueService;

  private final ProjectService projectService;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  @Value(value = "${app.cron.blueraven.marketo.enabled:false}")
  private Boolean marketoEnabled;

  public Optional<ProjectProcessStepEvent> insertPpsEvent(
      Long projectProcessStepId, Long processStepEventId) throws Exception {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("processStepEventId", processStepEventId);
    params.put("createdById", user.getId());

    Long id =
        sqlCache.updateBySqlReturningId(ProjectProcessStepEventQuery.insertEvent, params, "id").longValue();
    return getPpsEvent(projectProcessStepId, id);
  }

  public void deletePpsEvent(Long ppseId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("ppseId", ppseId);
    params.put("userId", user.getId());

    sqlCache.updateBySql(ProjectProcessStepEventQuery.delete, params);
  }

  public List<CompanyEventStatusType> getCancelledAssignedToPpsEvent(Long ppseId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ppseId", ppseId);

    return sqlCache.queryBySql(ProjectProcessStepEventQuery.getCancelledAssignedToPpsEvent,
        params,
        CompanyEventStatusType.class);
  }

  public void setStatus(Long ppsId, Long projectProcessStepEventId, Long companyEventStatusTypeId)
      throws Exception {
    User user = securityService.getCurrentUser();
    Optional<ProjectProcessStepEvent> pps = getPpsEvent(ppsId, projectProcessStepEventId);

    if (pps.isEmpty()) {
      throw new RuntimeException("The given process step does not exist");
    }

    // dont change if already set to the same
    ProjectProcessStepEvent ppse = pps.get();
    if (ppse.getCompanyEventStatusTypeId().equals(companyEventStatusTypeId)) {
      return;
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepEventId", projectProcessStepEventId);
    params.put("companyEventStatusTypeId", companyEventStatusTypeId);
    params.put("userId", user.trueUserId());

    sqlCache.updateBySql(ProjectProcessStepEventQuery.setStatus, params);
  }

  public Optional<ProjectProcessStepEvent> getPpsEvent(Long ppsId, Long ppsEventId) throws Exception {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", ppsEventId);
    params.put("ppsId", ppsId);

    //using ppsId ensures that they cannot modify the url and have a mismatch of ppsId vs event.project_process_step_id
    Optional<ProjectProcessStepEvent> result =
        sqlCache.getBySql(ProjectProcessStepEventQuery.get,
            params,
            new PpsEventMapper<>(ProjectProcessStepEvent.class, om));
    if (result.isPresent()) {
      ProjectProcessStepEvent event = result.get();
      event.setCustomFieldGroups(
          customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.EVENT.toString(), ppsEventId));

      if (null != event.getEventActions() && !event.getEventActions().isEmpty()) {
        // if there are event actions, then check if the pps status change can be performed here
        for (ProcessStepEventAction action : event.getEventActions()) {
          // if the action doesn't change the pps status then allow it
          // or if the root pps status is currently active, then allow

          // get the requirements here - sames as humes, pass to canPermform
          List<Long> requirementIds =
              Objects.requireNonNull(action).getProcessStepEventLogicList().stream()
                  .filter(step -> step.getProcessStepEventRequirementId() != null)
                  .map(ProcessStepEventLogic::getProcessStepEventRequirementId)
                  .collect(Collectors.toList());

          List<ProjectProcessStepRequirement> requirements =
              projectProcessStepRequirementService.getByProjectProcessStepId(
                  event.getProjectProcessStepId(), requirementIds, true);

          action.setCanPerform(canPerformEventAction(event, action, requirements));
        }
      }
      if (null != event.getEventBanners() && !event.getEventBanners().isEmpty()) {
        // if there are event banners, do the checks
        for (ProcessStepEventAction action : event.getEventBanners()) {
          // get the requirements here - sames as humes, pass to canPermform
          List<Long> requirementIds =
            Objects.requireNonNull(action).getProcessStepEventLogicList().stream()
                   .filter(step -> step.getProcessStepEventRequirementId() != null)
                   .map(ProcessStepEventLogic::getProcessStepEventRequirementId)
                   .collect(Collectors.toList());

          List<ProjectProcessStepRequirement> requirements =
            projectProcessStepRequirementService.getByProjectProcessStepId(
              event.getProjectProcessStepId(), requirementIds, true);

          action.setCanPerform(canPerformEventAction(event, action, requirements));
        }
      }
    } else {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Event Not Found", new Exception());
    }
    return result;
  }

  public Boolean canPerformEventAction(
      ProjectProcessStepEvent event,
      ProcessStepEventAction action,
      List<ProjectProcessStepRequirement> requirements)
      throws Exception {
    // Allow actions to be triggered only once per PPS
    if (action.getAlreadyTriggered() && !action.getMultipleUses()) {
      return false;
    }

    // Only perform event actions on active project process steps
    if (!event.getRootProjectProcessStepStatusTypeId().equals(ProcessStepStatusType.ACTIVE.id)) {
      return false;
    }

    // Only perform event actions on active project process steps events
    if (!event
        .getEventStatusTypeId()
        .equals(com.albatross.api.v1.flow.enums.EventStatusType.ACTIVE.id)) {
      return false;
    }

    if (action.getAlwaysEnabled()) {
      return true;
    }

    // if there is logic, then check it all bitch
    if (!action.getProcessStepEventLogicList().isEmpty()) {

      for (ProjectProcessStepRequirement r : requirements) {
        try {
          r.setFulfilled(
              projectProcessStepService.isRequirementMet(r, event.getProjectProcessStepId(), event.getId()));
        } catch (Exception e) {
          log.error(
              String.format(
                  "PPSE: Exception while parsing date requirement value for process step event requirement ID: %s",
                  r.getId()));
          throw e;
        }
      }

      StringBuilder logicString = new StringBuilder();

      // This should now just be creating logic by making a string of all the requirements in order
      // and replacing requirementIds with their respective true/false value
      for (ProcessStepEventLogic logicStep : action.getProcessStepEventLogicList()) {
        if (logicStep.getOperationCode() != null) {
          logicString.append(" ").append(logicStep.getOperationCode()).append(" ");
        } else if (logicStep.getProcessStepEventRequirementId() != null) {
          Optional<ProjectProcessStepRequirement> requirement =
              requirements.stream()
                  .filter(r -> r.getId().equals(logicStep.getProcessStepEventRequirementId()))
                  .findFirst();
          requirement.ifPresent(r -> logicString.append(r.getFulfilled().toString()));
        }
      }

      ExpressionParser parser = new SpelExpressionParser();
      if (logicString.length() > 0) {
        // @TODO: humes, This is for debugging purposes
        //      final String tempString = logicString.toString().replaceAll("AND",
        // "&&").replaceAll("OR", "||");
        //      log.info(String.format("Logic string generated for actionId: %s, ppsId: %s, %s",
        // action.getId(), pps.getProjectProcessStepId(), tempString));
        //      log.info("hi" +
        // parser.parseExpression(logicString.toString()).getValue(Boolean.class));
        return parser.parseExpression(logicString.toString()).getValue(Boolean.class);
      } else {
        return requirements.stream().allMatch(ProcessStepRequirement::getFulfilled);
      }
    } else {
      return false;
    }

  }

  public Optional<ProjectProcessStepEvent> savePpsEventDetails(Long ppsId,
      Long eventId, ProjectProcessStepEventController.SaveEventRequest saveEvent) throws Exception {
    if (null != saveEvent.getStartTime()
        && null != saveEvent.getEndTime()
        && (saveEvent.getEndTime().before(saveEvent.getStartTime())
            || saveEvent.getEndTime().equals(saveEvent.getStartTime()))) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Start Time must be before End Time", new Exception());
    } else {
      User currentUser = securityService.getCurrentUser();

      HashMap<String, Object> params = new HashMap<>();
      params.put("id", eventId);
      params.put("startTime", saveEvent.getStartTime());
      params.put("endTime", saveEvent.getEndTime());
      params.put("resourceId", saveEvent.getResourceId());
      params.put("saveVersion", saveEvent.getSaveVersion());

      // mobile is not going to allow them to save this field so in the sql we check if this value
      // is null and we don't do anything if it is.
      params.put("companyEventStatusTypeId", saveEvent.getCompanyEventStatusTypeId());
      params.put("modifiedById", currentUser.getId());

      // can only do the save version check if we receive a saveVersion. initially mobile will not
      // be sending this in.
      // once mobile updates then we can remove the else statement here
      if (null != saveEvent.getSaveVersion()) {
        int countUpdatedRows =
            sqlCache.updateBySql(ProjectProcessStepEventQuery.savePpsEventDetails, params);
        if (countUpdatedRows == 0) {
          throw new ResponseStatusException(
              HttpStatus.BAD_REQUEST, "Save Version Mismatch", new Exception());
        }
      } else {
        sqlCache.updateBySql(ProjectProcessStepEventQuery.savePpsEventDetailsNoVersion, params);
      }

      if (null != saveEvent.getCustomFieldValues() && !saveEvent.getCustomFieldValues().isEmpty()) {
        // the fields sent in here are the dirty fields, save those
        customFieldValueService.updateCustomFieldValues(
            saveEvent.getCustomFieldValues(), eventId, ObjectType.EVENT.textValue());
      }

      return getPpsEvent(ppsId, eventId);
    }
  }

  public Optional<ProcessStepEventAction> getPpsEventAction(Long ppsEventId, Long actionId)
      throws Exception {
    // the main different of this vs processStepEventService.getStepEventAction() is that this one
    // know which ppse it is running on
    // so we can get/check the value of "alreadyTriggered", but it can still share the same Mapper
    HashMap<String, Object> params = new HashMap<>();
    params.put("ppsEventId", ppsEventId);
    params.put("actionId", actionId);

    return sqlCache.getBySql(ProjectProcessStepEventQuery.getPpsEventAction,
        params,
        new ProcessStepEventService.ProcessStepEventActionMapper<>(
            ProcessStepEventAction.class, om));
  }

  @Transactional
  public PpseActionResult performStepEventAction(Long ppsId, Long ppsEventId, Long actionId) throws Exception {
    /*
    **High level pseudo logic:**

    * gather required data
    * set the event to the desired status IF not already in that status
    * set the process step to the desired status IF not already in that status
    * do i need to perform auto triggers again if the PS status changed?  ...probably
    */

    //get the action so the frontend doesn't have to pass in the big ass object
    Optional<ProcessStepEventAction> psEventAction = getPpsEventAction(ppsEventId, actionId);

    if (psEventAction.isPresent()) {
      ProcessStepEventAction processStepEventAction = psEventAction.get();

      List<Long> requirementIds =
          Objects.requireNonNull(processStepEventAction).getProcessStepEventLogicList().stream()
              .filter(step -> step.getProcessStepEventRequirementId() != null)
              .map(ProcessStepEventLogic::getProcessStepEventRequirementId)
              .collect(Collectors.toList());

      HashMap<String, Object> eventParams = new HashMap<>();
      eventParams.put("id", ppsEventId);
      Optional<ProjectProcessStepEvent> event = sqlCache.getBySql(ProjectProcessStepEventQuery.getBasic, eventParams, ProjectProcessStepEvent.class);

      if (event.isPresent()) {
        List<ProjectProcessStepRequirement> requirements =
            projectProcessStepRequirementService.getByProjectProcessStepId(
                event.get().getProjectProcessStepId(), requirementIds, true);

        boolean canPerformAction =
            canPerformEventAction(event.get(), processStepEventAction, requirements);

        // double check if action can be run, if so, run it, otherwise throw an error
        if (canPerformAction) {
          User currentUser = securityService.getCurrentUser();

          HashMap<String, Object> params = new HashMap<>();
          params.put(
              "companyEventStatusTypeId", processStepEventAction.getCompanyEventStatusTypeId());
          params.put(
              "companyProcessStepStatusTypeId",
              processStepEventAction.getCompanyProcessStepStatusTypeId());
          params.put("actionName", processStepEventAction.getActionName());
          params.put("userId", currentUser.getId());
          params.put("ppsId", ppsId);
          params.put("projectProcessStepEventId", ppsEventId);

          Optional<ProjectProcessStepEvent> ppse = this.getPpsEvent(ppsId, ppsEventId);
          if (ppse.isEmpty()) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST, "Project Process Step Event Not Found", new Exception());
          } else {
            // check if event is already in the desired status, then update the ppse status to the
            // desired status if not already in it
            if (null != processStepEventAction.getCompanyEventStatusTypeId()
                && !ppse.get()
                    .getCompanyEventStatusTypeId()
                    .equals(processStepEventAction.getCompanyEventStatusTypeId())) {
              sqlCache.updateBySql(ProjectProcessStepEventQuery.updateCompanyEventStatus, params);
            }
          }

          ProjectProcessStep pps = projectProcessStepService.getProjectProcessStep(ppsId);
          boolean doAutoTriggers = false;
          //check if pps is already in the desired status, then update the pps status to the desired status if not already in it
          if (null != processStepEventAction.getCompanyProcessStepStatusTypeId() && !pps.getCompanyProcessStepStatusTypeId().equals(processStepEventAction.getCompanyProcessStepStatusTypeId())) {
            //do some validation here:
            //if pps is not active, then dont allow this.
            if (!pps.getProcessStepStatusTypeId().equals(ProcessStepStatusType.ACTIVE.id)) {
              throw new ResponseStatusException(
                  HttpStatus.BAD_REQUEST,
                  "Cannot run this action. Process Step Status must be Active.",
                  new Exception());
            }
            // update the pps status (if the new status is cancel, unset the primary flag)
            params.put(
                "primaryFlag",
                !processStepEventAction
                    .getRootProcessStepStatusTypeId()
                    .equals(ProcessStepStatusType.CANCELLED.id));
            sqlCache.updateBySql(ProjectProcessStepEventQuery.updatePpsStatus, params);

            // if the new status was cancel, check for a single existence of this PPS type in
            // Complete status and set as primary if only one found
            params.put("projectId", pps.getProjectId());
            params.put("processStepId", pps.getProcessStepId());
            sqlCache.updateBySql(ProjectProcessStepEventQuery.updatePrimaryIfOnlyOne, params);

            // if the new status was a root ACTIVE status then run pps auto triggers
            // only run if the referring project process step is active
            if (pps.getProcessStepStatusTypeId().equals(ProcessStepStatusType.ACTIVE.id)) {
              doAutoTriggers = true;
            }
          }

          PpseActionResult ppseActionResult = performChildFunctions(processStepEventAction.getId(), ppsEventId, pps.getProjectProcessStepId(), pps.getProcessStepId(), pps.getProjectId());
//          var childFunctionsRan = Boolean.parseBoolean(childFunctionResults.get("didFunctionsRun").toString());
          List<Long> newChildPpsIds = ppseActionResult.getNewChildPpsIds();

          List<ProjectProcessStepService.PpsActionResult> actionResults = new ArrayList<>();
          //moved this out of the status check section so we could do it after child functions have been run
          if(doAutoTriggers || ppseActionResult.getDidFunctionsRun()) {
            actionResults.add(projectProcessStepService.performAutoTriggerActions(pps.getProjectProcessStepId(), securityService.getCurrentUserDetails()));
          }

          //if the pps status was updated (or marked to be updated if the actual status didn't change)
          if (processStepEventAction.getCompanyProcessStepStatusTypeId() != null) {
            //run auto triggers for PPSs which use the new PPS status
            List<ProjectProcessStep> steps = sqlCache.queryBySql(ProjectProcessStepQuery.getUsingStatusByPpsIds, Map.of("projectProcessStepIds", List.of(pps.getProjectProcessStepId())), ProjectProcessStep.class);
            for(ProjectProcessStep step : steps) {
              //only run if the referring PPS is active and not the parent PPS
              if(step.getProcessStepStatusTypeId().equals(ProcessStepStatusType.ACTIVE.id) && !Objects.equals(pps.getProjectProcessStepId(), step.getProjectProcessStepId())) {
                actionResults.add(projectProcessStepService.performAutoTriggerActions(step.getProjectProcessStepId(), securityService.getCurrentUserDetails()));
              }
            }
          }

          //if new PPSs were created by DB functions, run through autotriggers
          if (ppseActionResult.getDidFunctionsRun() && !newChildPpsIds.isEmpty()) {
            for (Long newPpsId : newChildPpsIds) {
              actionResults.add(projectProcessStepService.performAutoTriggerActions(newPpsId, securityService.getCurrentUserDetails()));

              //run auto triggers for PPSs which use the new PPS status
              List<ProjectProcessStep> steps = sqlCache.queryBySql(ProjectProcessStepQuery.getUsingStatusByPpsIds, Map.of("projectProcessStepIds", List.of(pps.getProjectProcessStepId())), ProjectProcessStep.class);
              for(ProjectProcessStep step : steps) {
                //only run if the referring PPS is active and not the parent PPS (which shouldn't happen since these are newly created PPSs)
                //it's assumed the DB function that created this new ID put it in an active status/category
                if(step.getProcessStepStatusTypeId().equals(ProcessStepStatusType.ACTIVE.id) && !Objects.equals(pps.getProjectProcessStepId(), step.getProjectProcessStepId())) {
                  actionResults.add(projectProcessStepService.performAutoTriggerActions(newPpsId, securityService.getCurrentUserDetails()));
                }
              }
            }
          }

          // if we made it to here then insert a record of having run the event
          params.put("processStepEventActionId", processStepEventAction.getId());
          params.put("createdById", currentUser.getId());
          params.put("allowMultipleUses", processStepEventAction.getMultipleUses());
          sqlCache.updateBySql(ProjectProcessStepEventQuery.insertAuditRow, params);

          ppseActionResult.setPpsEventId(ppsEventId);
          ppseActionResult.setProjectId(pps.getProjectId());

          //if the manually triggered action did not tell us to run project tag updates, then check if any of the auto triggered ones did.
          if(!ppseActionResult.getShouldRunProjectTagUpdate()) {
            boolean doTagUpdate = actionResults.stream().anyMatch(ProjectProcessStepService.PpsActionResult::getShouldRunProjectTagUpdate);
            ppseActionResult.setShouldRunProjectTagUpdate(doTagUpdate);
          }

          return ppseActionResult;
//          return ResponseEntity.ok(getPpsEvent(ppsId, ppsEventId));
        } else {
          throw new ResponseStatusException(
              HttpStatus.PRECONDITION_FAILED,
              "The requirements for this event action were not met.",
              new Exception());
        }
      } else {
        throw new ResponseStatusException(
            HttpStatus.NOT_FOUND, "This event could not be found.", new Exception());
      }
    } else {
      throw new ResponseStatusException(
          HttpStatus.NOT_FOUND, "This action could not be found.", new Exception());
    }
  }


  @Data
  public static class PpseActionResult {
    private Boolean didFunctionsRun;
    private Boolean shouldRunProjectTagUpdate;
    private List<Long> newChildPpsIds = new ArrayList<>();
    private Long ppsEventId, projectId;
  }

  /**
   *
   * @param actionId
   * @param ppsEventId
   * @param ppsId
   * @param processStepId
   * @param projectId
   * @return Map<String, Object> The returned map will have 2 keys:
   *  didFunctionsRun: Boolean, true if any DB function was successfully ran, false otherwise
   *  newChildPpsIds: List<Long>, List of all newly created PPS IDs
   */
  public PpseActionResult performChildFunctions(Long actionId, Long ppsEventId, Long ppsId, Long processStepId, Long projectId) {
    PpseActionResult ppseActionResult = new PpseActionResult();
    ppseActionResult.setDidFunctionsRun(false);
    List<Long> newChildPpsIds = new ArrayList<>();
    List<ProcessStepEventActionChildFunction> childFunctions = processStepEventService.getChildFunctionsWithParamValues(actionId, ppsEventId);
    AtomicBoolean doProjectTagUpdate = new AtomicBoolean(false);
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
          systemValues.put("ppsEventId", ppsEventId);

          if (functionAbbreviation.equals("brs")) {
            var functionClass = new BrsProcessStepActionFunctionService(sqlCache, goodleapService, auroraService, marketoService, listOfValueService);
            functionClass.marketoEnabled = marketoEnabled;
            Method method = BrsProcessStepActionFunctionService.class.getMethod(functionName, ProcessStepActionChildFunction.class, Map.class);
            method.invoke(functionClass, childFunction, systemValues);
          } else {
            // @TODO: Add company IDs here during onboarding
          }
        } else {
          if(childFunction.getFunctionName().equals("flow.assign_tag_to_project")) {
            doProjectTagUpdate.set(true);
          }
          String params = String.join(", ", projectProcessStepService.prepareFunctionParams(childFunction.getCompanyFunctionParams(), childFunction.getProjectId(), processStepId, ppsId, ppsEventId));
          String query = String.format("select * from %s(%s)", childFunction.getFunctionName(), params);
          Optional<Object> newChildPpsId = sqlCache.getBySql(query, null, new SingleColumnRowMapper<>(Object.class));
          if (childFunction.getCreatesPps() && newChildPpsId.isPresent()) {
            try {
              final Long newPpsId = Long.parseLong(newChildPpsId.get().toString());
              newChildPpsIds.add(newPpsId);
            } catch (Exception e) {
              //noop, the DB function didn't return a PPS ID
            }
          }
        }
      } catch (InvocationTargetException e) {
        throw new RuntimeException(String.format("PPS: Unable to run child action function. CFA ID: %s, action ID: %s, PPS ID: %s *** %s", childFunction.getId(), actionId, ppsId, e.getCause().getMessage()));
      } catch (Exception e) {
        throw new RuntimeException(String.format("PPS: Unable to run child action function. CFA ID: %s, action ID: %s, PPS ID: %s *** %s", childFunction.getId(), actionId, ppsId, e.getMessage()));
      }
    });

    if (!childFunctions.isEmpty()) {
      ppseActionResult.setDidFunctionsRun(true);
    }
    ppseActionResult.setShouldRunProjectTagUpdate(doProjectTagUpdate.get());
    ppseActionResult.setNewChildPpsIds(newChildPpsIds);
    return ppseActionResult;
  }

  public List<Attachment> getProjectProcessStepEventAttachments(Long projectProcessStepEventId, Boolean isMobile, Boolean linked) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepEventId", projectProcessStepEventId);
    params.put("linked", linked);
    params.put("companyId", currentUser.getCompanyId());
    // there is currently no where in the UI where event attachments are not viewed side by side
    // with ps attachments, so for now this actually returns both
    List<Attachment> attachments =
        sqlCache.queryBySql(ProjectProcessStepEventQuery.getProjectProcessStepEventAttachments,
            params,
            Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(
        attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  public void linkAttachment(Long projectProcessStepEventId, Long attachmentId, Boolean doLink) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepEventId", projectProcessStepEventId);
    params.put("attachmentId", attachmentId);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    String sql = ProjectProcessStepEventQuery.linkAttachment;
    if(!doLink) {
      sql = ProjectProcessStepEventQuery.unlinkAttachment;
    }
    sqlCache.updateBySql(sql, params);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped
  // code right now and I hate it
  public Attachment addAttachment(
      MultipartFile file, Long projectProcessStepEventId, Long attachmentTypeId, String displayName)
      throws IOException {
    User user = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    // had to change this so that a parent looking at a child project could still see project
    // statuses
    HashMap<String, Object> p2 = new HashMap<>();
    p2.put("sourceId", projectProcessStepEventId);
    Long companyId =
        sqlCache.queryForObjectBySql(ProjectProcessStepEventQuery.getCompanyId, p2, Long.class);

    // get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key =
        String.format(
            user.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    metadata.setContentType(file.getContentType());

    PutObjectRequest objectRequest =
        new PutObjectRequest(
            storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

    s3.putObject(objectRequest.withCannedAcl(CannedAccessControlList.PublicRead));

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", CleanString.cleanFilename(file.getOriginalFilename()));
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("createdById", user.getId());
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("displayName", displayName.length() > 100 ? displayName.substring(0, 100) : displayName);
    params.put("companyId", companyId);

    Long attachmentId = sqlCache.updateBySqlReturningId(AttachmentQuery.create, params, "id").longValue();

    params.clear();
    params.put("projectProcessStepEventId", projectProcessStepEventId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", user.getId());

    sqlCache.updateBySql(ProjectProcessStepEventQuery.addAttachment, params);

    return attachmentService.findById(attachmentId);
  }

  public Optional<ProjectProcessStepEvent> getActiveCloserAppointment(Long projectId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("companyId", user.getCompanyId());
    return sqlCache.getBySql(ProjectProcessStepEventQuery.getActiveCloserAppointment, params, ProjectProcessStepEvent.class);
  }

  public Optional<ProjectProcessStepEvent> getActiveAhjInspectionWork(Long projectId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("companyId", user.getCompanyId());
    return sqlCache.getBySql(ProjectProcessStepEventQuery.getActiveAhjInspectionWork, params, ProjectProcessStepEvent.class);
  }

  public Optional<ProjectProcessStepEvent> getActiveInstallation(Long projectId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("companyId", user.getCompanyId());
    return sqlCache.getBySql(ProjectProcessStepEventQuery.getActiveInstallation, params, ProjectProcessStepEvent.class);
  }

  public static class PpsEventMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public PpsEventMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ProcessStepEventAction>> eventActionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "eventActions",
          new JsonCollectionDeserializer(eventActionsRef, objectMapper));
      bw.registerCustomEditor(
        List.class,
        "eventBanners",
        new JsonCollectionDeserializer(eventActionsRef, objectMapper));

      TypeReference<List<ProjectProcessStepEvent.Resource>> availableResourcesRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "availableResources",
          new JsonCollectionDeserializer(availableResourcesRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> startTimeWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "startTimeWhiteListedPositions",
          new JsonCollectionDeserializer(startTimeWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> endTimeWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "endTimeWhiteListedPositions",
          new JsonCollectionDeserializer(endTimeWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> resourceWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "resourceWhiteListedPositions",
          new JsonCollectionDeserializer(resourceWhiteListedPositionsRef, objectMapper));
    }
  }
}
