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
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


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
  private final AttachmentService attachmentService;
  private final AmazonS3 s3;
  private final ObjectMapper om;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public Optional<ProjectProcessStepEvent> insertPpsEvent(Long projectProcessStepId, ProcessStepEvent processStepEvent) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("processStepEventId", processStepEvent.getId());
    params.put("companyEventStatusTypeId", processStepEvent.getId());
    params.put("createdById", user.getId());

    Long id = sqlCache.updateReturningId("projectProcessStepEvent.insertEvent", params, "id").longValue();
    return getPpsEvent(id);
  }

  public Optional<ProjectProcessStepEvent> getPpsEvent(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProjectProcessStepEvent> result = sqlCache.get("projectProcessStepEvent.get", params, new PpsEventMapper<>(ProjectProcessStepEvent.class, om));
    if(result.isPresent()) {
      result.get().setCustomFieldGroups(customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.EVENT.toString(), id));
    }
    return result;
  }
  public Optional<ProjectProcessStepEvent> savePpsEventDetails(ProjectProcessStepEvent ppsEvent) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", ppsEvent.getId());
    params.put("startTime", ppsEvent.getStartTime());
    params.put("endTime", ppsEvent.getEndTime());
    params.put("resourceId", ppsEvent.getResourceId());
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("projectProcessStepEvent.savePpsEventDetails", params);

    return getPpsEvent(ppsEvent.getId());
  }

  public void performStepEventAction(Long ppsId, Long eventId, ProcessStepEventAction processStepEventAction) {
    /*
     **High level pseudo logic:**

     * gather required data
     * set the event to the desired status IF not already in that status
     * set the process step to the desired status IF not already in that status
     * do i need to perform auto triggers again if the PS status changed?  ...probably
     */
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyEventStatusTypeId", processStepEventAction.getCompanyEventStatusTypeId());
    params.put("companyProcessStepStatusTypeId", processStepEventAction.getCompanyProcessStepStatusTypeId());
    params.put("actionName", processStepEventAction.getActionName());
    params.put("userId", currentUser.getId());
    params.put("ppsId", ppsId);
    params.put("projectProcessStepEventId", eventId);

    log.info("WE WILL PERFORM ACTION: {}", processStepEventAction.getActionName());

    Optional<ProjectProcessStepEvent> ppse = this.getPpsEvent(eventId);
    if(ppse.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Project Process Step Event Not Found", new Exception());
    } else {
      //check if event is already in the desired status, then update the ppse status to the desired status if not already in it
      if(null != processStepEventAction.getCompanyEventStatusTypeId() && !ppse.get().getCompanyEventStatusTypeId().equals(processStepEventAction.getCompanyEventStatusTypeId())) {
        sqlCache.update("projectProcessStepEvent.updateCompanyEventStatus", params);
      }
    }

    ProjectProcessStep pps = projectProcessStepService.getProjectProcessStep(ppsId);
    //check if pps is already in the desired status, then update the pps status to the desired status if not already in it
    if(null != processStepEventAction.getCompanyProcessStepStatusTypeId() && !pps.getCompanyProcessStepStatusTypeId().equals(processStepEventAction.getCompanyProcessStepStatusTypeId())) {
      //this is a total hack just to see it update.  needs to follow all the same rules as the other types of actions re: cancellations, reactivations, etc
      sqlCache.update("projectProcessStepEvent.randaHacking", params);
    }

  }

  public List<Attachment> getProjectProcessStepEventAttachments(Long projectProcessStepEventId, Boolean isMobile) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepEventId", projectProcessStepEventId);
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
    }
  }

}
