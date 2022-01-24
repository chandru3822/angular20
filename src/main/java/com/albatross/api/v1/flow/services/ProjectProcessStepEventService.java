package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
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
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import com.albatross.api.v1.flow.enums.ProcessStepStatusType;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;


//@TODO: Had to make private functions public in this class to be able to unit test due to this issue. https://github.com/powermock/powermock/issues/929
// I don't like it and would rather have them be private. Change back if/when possible

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectProcessStepEventService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldValueService customFieldValueService;
  private final ProjectProcessStepService projectProcessStepService;
  private final ProjectProcessStepRequirementService projectProcessStepRequirementService;
  private final AttachmentService attachmentService;
  private final AmazonS3 s3;
  private final ObjectMapper om;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public Optional<ProjectProcessStepEvent> insertPpsEvent(Long projectProcessStepId, Long processStepEventId) throws Exception {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("processStepEventId", processStepEventId);
    params.put("createdById", user.getId());

    Long id = sqlCache.updateReturningId("projectProcessStepEvent.insertEvent", params, "id").longValue();
    return getPpsEvent(id);
  }

  public void deletePpsEvent(Long ppseId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("ppseId", ppseId);
    params.put("userId", user.getId());

    sqlCache.update("projectProcessStepEvent.delete", params, "id");
  }


  public Optional<ProjectProcessStepEvent> getPpsEvent(Long id) throws Exception {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProjectProcessStepEvent> result = sqlCache.get("projectProcessStepEvent.get", params, new PpsEventMapper<>(ProjectProcessStepEvent.class, om));
    if (result.isPresent()) {
      ProjectProcessStepEvent event = result.get();
      event.setCustomFieldGroups(customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.EVENT.toString(), id));

      if (null != event.getEventActions() && !event.getEventActions().isEmpty()) {
        //if there are event actions, then check if the pps status change can be performed here
        for (ProcessStepEventAction action : event.getEventActions()) {
          //if the action doesn't change the pps status then allow it
          //or if the root pps status is currently active, then allow

          //get the requirements here - sames as humes, pass to canPermform
          List<Long> requirementIds = Objects.requireNonNull(action).getProcessStepEventLogicList().stream()
            .filter(step -> step.getProcessStepEventRequirementId() != null)
            .map(ProcessStepEventLogic::getProcessStepEventRequirementId)
            .collect(Collectors.toList());

          List<ProjectProcessStepRequirement> requirements = projectProcessStepRequirementService.getByProjectProcessStepId(event.getProjectProcessStepId(), requirementIds, true);

          action.setCanPerform(canPerformEventAction(event, action, requirements));
        }
      }
    }
    return result;
  }

  public Boolean canPerformEventAction(ProjectProcessStepEvent event, ProcessStepEventAction action, List<ProjectProcessStepRequirement> requirements) throws Exception {
    // Allow actions to be triggered only once per PPS
    if (action.getAlreadyTriggered() && !action.getMultipleUses()) {
      return false;
    }

    //Only perform event actions on active project process steps
    if (!event.getRootProjectProcessStepStatusTypeId().equals(ProcessStepStatusType.ACTIVE.id)) {
      return false;
    }

    //Only perform event actions on active project process steps events
    if (!event.getEventStatusTypeId().equals(com.albatross.api.v1.flow.enums.EventStatusType.ACTIVE.id)) {
      return false;
    }

    //if there is logic, then check it all bitch
    if (!action.getProcessStepEventLogicList().isEmpty()) {

      for (ProjectProcessStepRequirement r : requirements) {
        try {
          r.setFulfilled(projectProcessStepService.isRequirementMet(r, event.getProjectProcessStepId()));
        } catch (Exception e) {
          log.error(String.format("PPSE: Exception while parsing date requirement value for process step event requirement ID: %s", r.getId()));
          e.printStackTrace();
          throw e;
        }
      }

      StringBuilder logicString = new StringBuilder();

      // This should now just be creating logic by making a string of all the requirements in order and replacing requirementIds with their respective true/false value
      for (ProcessStepEventLogic logicStep : action.getProcessStepEventLogicList()) {
        if (logicStep.getOperationCode() != null) {
          logicString.append(" ").append(logicStep.getOperationCode()).append(" ");
        } else if (logicStep.getProcessStepEventRequirementId() != null) {
          Optional<ProjectProcessStepRequirement> requirement = requirements.stream().filter(r -> r.getId().equals(logicStep.getProcessStepEventRequirementId())).findFirst();
          requirement.ifPresent(r -> logicString.append(r.getFulfilled().toString()));
        }
      }

      ExpressionParser parser = new SpelExpressionParser();
      if (logicString.length() > 0) {
        // @TODO: humes, This is for debugging purposes
//      final String tempString = logicString.toString().replaceAll("AND", "&&").replaceAll("OR", "||");
//      log.info(String.format("Logic string generated for actionId: %s, ppsId: %s, %s", action.getId(), pps.getProjectProcessStepId(), tempString));
//      log.info("hi" + parser.parseExpression(logicString.toString()).getValue(Boolean.class));
        return parser.parseExpression(logicString.toString()).getValue(Boolean.class);
      } else {
        return requirements.stream().allMatch(ProcessStepRequirement::getFulfilled);
      }

    }


    return true;
  }

  public Optional<ProjectProcessStepEvent> savePpsEventDetails(Long eventId, ProjectProcessStepEvent ppsEvent) throws Exception {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", eventId);
    params.put("startTime", ppsEvent.getStartTime());
    params.put("endTime", ppsEvent.getEndTime());
    params.put("resourceId", ppsEvent.getResourceId());
    params.put("companyEventStatusTypeId", ppsEvent.getCompanyEventStatusTypeId());
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("projectProcessStepEvent.savePpsEventDetails", params);

    return getPpsEvent(ppsEvent.getId());
  }

  public Optional<ProcessStepEventAction> getPpsEventAction(Long ppsEventId, Long actionId) throws Exception {
    //the main different of this vs processStepEventService.getStepEventAction() is that this one know which ppse it is running on
    //so we can get/check the value of "alreadyTriggered", but it can still share the same Mapper
    HashMap<String, Object> params = new HashMap<>();
    params.put("ppsEventId", ppsEventId);
    params.put("actionId", actionId);

    Optional<ProcessStepEventAction> result = sqlCache.get("projectProcessStepEvent.getPpsEventAction", params, new ProcessStepEventService.ProcessStepEventActionMapper<>(ProcessStepEventAction.class, om));

    return result;
  }

  public ResponseEntity<Object> performStepEventAction(Long ppsId, Long eventId, Long actionId) throws Exception {
    /*
     **High level pseudo logic:**

     * gather required data
     * set the event to the desired status IF not already in that status
     * set the process step to the desired status IF not already in that status
     * do i need to perform auto triggers again if the PS status changed?  ...probably
     */

    //get the action so the frontend doesn't have to pass in the big ass object
    Optional<ProcessStepEventAction> psEventAction = getPpsEventAction(eventId, actionId);

    if (psEventAction.isPresent()) {
      ProcessStepEventAction processStepEventAction = psEventAction.get();

      List<Long> requirementIds = Objects.requireNonNull(processStepEventAction).getProcessStepEventLogicList().stream()
        .filter(step -> step.getProcessStepEventRequirementId() != null)
        .map(ProcessStepEventLogic::getProcessStepEventRequirementId)
        .collect(Collectors.toList());

      HashMap<String, Object> eventParams = new HashMap<>();
      eventParams.put("id", eventId);
      Optional<ProjectProcessStepEvent> event = sqlCache.get("projectProcessStepEvent.getBasic", eventParams, ProjectProcessStepEvent.class);

      if (event.isPresent()) {
        List<ProjectProcessStepRequirement> requirements = projectProcessStepRequirementService.getByProjectProcessStepId(event.get().getProjectProcessStepId(), requirementIds, true);

        boolean canPerformAction = canPerformEventAction(event.get(), processStepEventAction, requirements);

        //double check if action can be run, if so, run it, otherwise throw an error
        if (canPerformAction) {
          User currentUser = securityService.getCurrentUser();

          HashMap<String, Object> params = new HashMap<>();
          params.put("companyEventStatusTypeId", processStepEventAction.getCompanyEventStatusTypeId());
          params.put("companyProcessStepStatusTypeId", processStepEventAction.getCompanyProcessStepStatusTypeId());
          params.put("actionName", processStepEventAction.getActionName());
          params.put("userId", currentUser.getId());
          params.put("ppsId", ppsId);
          params.put("projectProcessStepEventId", eventId);

          Optional<ProjectProcessStepEvent> ppse = this.getPpsEvent(eventId);
          if (ppse.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Project Process Step Event Not Found", new Exception());
          } else {
            //check if event is already in the desired status, then update the ppse status to the desired status if not already in it
            if (null != processStepEventAction.getCompanyEventStatusTypeId() && !ppse.get().getCompanyEventStatusTypeId().equals(processStepEventAction.getCompanyEventStatusTypeId())) {
              sqlCache.update("projectProcessStepEvent.updateCompanyEventStatus", params);
            }
          }

          ProjectProcessStep pps = projectProcessStepService.getProjectProcessStep(ppsId);
          //check if pps is already in the desired status, then update the pps status to the desired status if not already in it
          if (null != processStepEventAction.getCompanyProcessStepStatusTypeId() && !pps.getCompanyProcessStepStatusTypeId().equals(processStepEventAction.getCompanyProcessStepStatusTypeId())) {
            //do some validation here:
            //if pps is not active, then dont allow this.
            if (!pps.getProcessStepStatusTypeId().equals(ProcessStepStatusType.ACTIVE.id)) {
              throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cannot run this action. Process Step Status must be Active.", new Exception());
            }
            //update the pps status (if the new status is cancel, unset the primary flag)
            params.put("primaryFlag", !processStepEventAction.getRootProcessStepStatusTypeId().equals(ProcessStepStatusType.CANCELLED.id));
            sqlCache.update("projectProcessStepEvent.updatePpsStatus", params);

            //if the new status was cancel, check for a single existence of this PPS type in Complete status and set as primary if only one found
            params.put("projectId", pps.getProjectId());
            params.put("processStepId", pps.getProcessStepId());
            sqlCache.update("projectProcessStepEvent.updatePrimaryIfOnlyOne", params);

            //if the new status was a root ACTIVE status then run pps auto triggers
            //only run if the referring project process step is active
            if (pps.getProcessStepStatusTypeId().equals(ProcessStepStatusType.ACTIVE.id)) {
              projectProcessStepService.performAutoTriggerActions(pps.getProjectProcessStepId(), securityService.getCurrentUserDetails());
            }
          }

          //if we made it to here then insert a record of having run the event
          params.put("processStepEventActionId", processStepEventAction.getId());
          params.put("createdById", currentUser.getId());
          params.put("allowMultipleUses", processStepEventAction.getMultipleUses());
          sqlCache.update("projectProcessStepEvent.insertAuditRow", params);

          return ResponseEntity.ok(getPpsEvent(eventId));
        } else {
          throw new ResponseStatusException(HttpStatus.PRECONDITION_FAILED, "The requirements for this event action were not met.", new Exception());
        }
      } else {
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "This event could not be found.", new Exception());
      }
    } else {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "This action could not be found.", new Exception());
    }

  }

  public List<Attachment> getProjectProcessStepEventAttachments(Long projectProcessStepEventId, Boolean isMobile) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepEventId", projectProcessStepEventId);
    //there is currently no where in the UI where event attachments are not viewed side by side with ps attachments, so for now this actually returns both
    List<Attachment> attachments = sqlCache.query("projectProcessStepEvent.getProjectProcessStepEventAttachments", params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped code right now and I hate it
  public Attachment addAttachment(MultipartFile file, Long projectProcessStepEventId, Long attachmentTypeId) throws IOException {
    User user = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    //had to change this so that a parent looking at a child project could still see project statuses
    HashMap<String, Object> p2 = new HashMap<>();
    p2.put("sourceId", projectProcessStepEventId);
    Long companyId = sqlCache.queryForObject("projectProcessStepEvent.getCompanyId", p2, Long.class);

    //get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key = String.format(user.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

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
    params.put("projectProcessStepEventId", projectProcessStepEventId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", user.getId());

    sqlCache.update("projectProcessStepEvent.addAttachment", params);

    return attachmentService.findById(attachmentId);
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
      bw.registerCustomEditor(List.class, "eventActions",
        new JsonCollectionDeserializer(eventActionsRef, objectMapper));

      TypeReference<List<ProjectProcessStepEvent.Resource>> availableResourcesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "availableResources",
        new JsonCollectionDeserializer(availableResourcesRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> startTimeWhiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "startTimeWhiteListedPositions",
        new JsonCollectionDeserializer(startTimeWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> endTimeWhiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "endTimeWhiteListedPositions",
        new JsonCollectionDeserializer(endTimeWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> resourceWhiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "resourceWhiteListedPositions",
        new JsonCollectionDeserializer(resourceWhiteListedPositionsRef, objectMapper));
    }
  }

}
