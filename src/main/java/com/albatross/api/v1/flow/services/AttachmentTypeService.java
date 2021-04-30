package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.KeyPattern;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.ProcessStepAttachmentType;
import com.albatross.api.v1.flow.model.ProjectAttachmentType;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

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
public class AttachmentTypeService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<AttachmentType> getAttachmentTypesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<AttachmentType> attachmentTypes = sqlCache.query("attachmentType.getTypesForCompany", params, AttachmentType.class);
    return attachmentTypes;
  }

  public void updateOrderInProcessStep(List<ProcessStepAttachmentType> attachmentTypes) {
    for(ProcessStepAttachmentType at : attachmentTypes){
      updateTypeOrderInProcessStep(at);
    }
  }

  public void updateTypeOrderInProcessStep(ProcessStepAttachmentType attachmentType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", attachmentType.getId());
    params.put("modifiedById", currentUser.getId());
    params.put("displayOrder", attachmentType.getDisplayOrder());

    sqlCache.update("attachmentType.updateTypeOrderInProcessStep", params);
  }

  public void updateOrderInProject(List<ProjectAttachmentType> attachmentTypes) {
    for(ProjectAttachmentType at : attachmentTypes){
      updateTypeOrderInProject(at);
    }
  }

  public void updateTypeOrderInProject(ProjectAttachmentType attachmentType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", attachmentType.getId());
    params.put("modifiedById", currentUser.getId());
    params.put("displayOrder", attachmentType.getDisplayOrder());

    sqlCache.update("attachmentType.updateTypeOrderInProject", params);
  }

  public void updateReadOnly(ProjectAttachmentType attachmentType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", attachmentType.getId());
    params.put("modifiedById", currentUser.getId());
    params.put("readOnly", attachmentType.getReadOnly());

    sqlCache.update("attachmentType.updateReadyOnly", params);
  }

  public List<AttachmentType> getAvailableTypesForProcessStep(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);

    List<AttachmentType> attachmentTypes = sqlCache.query("attachmentType.getAvailableTypesForProcessStep", params, AttachmentType.class);
    return attachmentTypes;
  }

  public List<AttachmentType> getAttachmentTypesForProject() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<AttachmentType> attachmentTypes = sqlCache.query("attachmentType.getAttachmentTypesForProject", params, AttachmentType.class);
    return attachmentTypes;
  }

  public Optional<AttachmentType> getType(Long companyId, Long typeId) {
    return sqlCache.get("attachmentType.getType",
        ImmutableMap.of("companyId", companyId,
            "typeId", typeId),
        AttachmentType.class);
  }

  public void deleteProcessStepType(Long id) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update("attachmentType.deleteProcessStepType",
        ImmutableMap.of("id", id,
            "modifiedById", currentUser.getId()));
  }

  public Optional<ProcessStepAttachmentType> getProcessStepType(Long id) {
    Optional<ProcessStepAttachmentType> result = sqlCache.get("attachmentType.getProcessStepType",
        ImmutableMap.of("id", id), ProcessStepAttachmentType.class);

    return result;
  }

  public List<ProcessStepAttachmentType> getProcessStepTypes(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    return sqlCache.query("attachmentType.getProcessStepTypes", params, ProcessStepAttachmentType.class);
  }

  public Optional<ProcessStepAttachmentType> insertProcessStepType(ProcessStepAttachmentType attachmentType) {
    User currentUser = securityService.getCurrentUser();

    Long id = sqlCache.updateReturningId("attachmentType.insertProcessStepType",
        ImmutableMap.of("createdById", currentUser.getId(),
            "attachmentTypeId", attachmentType.getAttachmentTypeId(),
            "processStepId", attachmentType.getProcessStepId()), "id").longValue();

    return getProcessStepType(id);
  }

  public void deleteProjectType(Long id) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update("attachmentType.deleteProjectType",
        ImmutableMap.of("id", id,
            "modifiedById", currentUser.getId()));
  }

  public Optional<ProjectAttachmentType> getProjectType(Long id) {
    Optional<ProjectAttachmentType> result = sqlCache.get("attachmentType.getProjectType",
        ImmutableMap.of("id", id), ProjectAttachmentType.class);

    return result;
  }

  public List<ProjectAttachmentType> getProjectTypes(Long projectId) {
    User currentUser = securityService.getCurrentUser();
    Long companyId = currentUser.getCompanyId();

    if(null != projectId) {
      //had to change this so that a parent looking at a child project could still see attachments
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      Optional<Long> overrideCompanyId = sqlCache.queryForObjectOptional("project.getCompanyId", params, Long.class);
      if(overrideCompanyId.isPresent()) {
        companyId = overrideCompanyId.get();
      } else {
        log.info("ATTACHMENT: No Company ID found for project. {}", projectId);
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No Company ID found for that project", new Exception());
      }
    }

    List<ProjectAttachmentType> result = sqlCache.query("attachmentType.getProjectTypes",
      ImmutableMap.of("companyId", companyId), ProjectAttachmentType.class);

    return result;
  }

  public Optional<ProjectAttachmentType> insertProjectType(ProjectAttachmentType attachmentType) {
    User currentUser = securityService.getCurrentUser();

    Long id = sqlCache.updateReturningId("attachmentType.insertProjectType",
        ImmutableMap.of("createdById", currentUser.getId(),
            "attachmentTypeId", attachmentType.getAttachmentTypeId(),
            "companyId", currentUser.getCompanyId()), "id").longValue();

    return getProjectType(id);
  }

  public void deleteType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update("attachmentType.deleteType",
        ImmutableMap.of("id", typeId,
                        "modifiedById", currentUser.getId()));
  }

  public void updateType(AttachmentType type) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update("attachmentType.updateType",
        ImmutableMap.of("companyId", type.getCompanyId(),
            "id", type.getId(),
            "attachmentType", type.getAttachmentType(),
            "modifiedById", currentUser.getId()));
  }

  public Optional<AttachmentType> insertType(AttachmentType type) {
    User currentUser = securityService.getCurrentUser();

    //all user added attachment types use the uploads key pattern (id = 9)

    Long id = sqlCache.updateReturningId("attachmentType.insertType",
        ImmutableMap.of("attachmentType", type.getAttachmentType(),
            "companyId", type.getCompanyId(),
            "keyPatternId", KeyPattern.UPLOADS.id,
            "createdById", currentUser.getId()),
        "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
