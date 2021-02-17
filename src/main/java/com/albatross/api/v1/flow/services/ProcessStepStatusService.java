package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ProcessStepStatusService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<ProcessStepStatusType> getStatusTypes() {
    List<ProcessStepStatusType> results = sqlCache.query("processStepStatus.getTypes", Collections.emptyMap(), ProcessStepStatusType.class);
    return results;
  }

  public List<CompanyProcessStepStatusType> getStatusTypesForCompany(Long projectId, Long projectProcessStepId) {
    User user = securityService.getCurrentUser();
    Long companyId = user.getCompanyId();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    if(null != projectId) {
      //had to change this so that a parent looking at a child project process step could will get the right statuses back
      HashMap<String, Object> p1 = new HashMap<>();
      p1.put("projectId", projectId);
      companyId = sqlCache.queryForObject("project.getCompanyId", p1, Long.class);
    } else if(null != projectProcessStepId) {
      //had to change this so that a parent looking at a child project process step could will get the right statuses back
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("projectProcessStepId", projectProcessStepId);
      companyId = sqlCache.queryForObject("projectProcessStep.getCompanyId", p2, Long.class);
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    //if a projectId or projectProcessStepId is sent in, use that company even if isParent is true
    params.put("parentOverride", null != projectId || null != projectProcessStepId);

    List<CompanyProcessStepStatusType> companyProcessStepStatusTypes = sqlCache.query("processStepStatus.getTypesForCompany", params, CompanyProcessStepStatusType.class);
    return companyProcessStepStatusTypes;
  }

  public List<CompanyProcessStepStatusType> getAvailableForProcessStep(Long processStepId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("companyId", user.getCompanyId());

    List<CompanyProcessStepStatusType> companyProcessStepStatusTypes = sqlCache.query("processStepStatus.availableForProcessStep", params, CompanyProcessStepStatusType.class);
    return companyProcessStepStatusTypes;
  }

  public List<CompanyProcessStepStatusType> getCancelledCompanyStatusTypesForCompany(Long projectId, Long projectProcessStepId) {
    User user = securityService.getCurrentUser();
    Long companyId = user.getCompanyId();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    if(null != projectId) {
      //had to change this so that a parent looking at a child project process step could will get the right statuses back
      HashMap<String, Object> p1 = new HashMap<>();
      p1.put("projectId", projectId);
      companyId = sqlCache.queryForObject("project.getCompanyId", p1, Long.class);
    } else if(null != projectProcessStepId) {
      //had to change this so that a parent looking at a child project process step could will get the right statuses back
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("projectProcessStepId", projectProcessStepId);
      companyId = sqlCache.queryForObject("projectProcessStep.getCompanyId", p2, Long.class);
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    //if a projectId or projectProcessStepId is sent in, use that company even if isParent is true
    params.put("parentOverride", null != projectId || null != projectProcessStepId);

    List<CompanyProcessStepStatusType> companyProcessStepStatusTypes = sqlCache.query("processStepStatus.getCancelledTypesForCompany", params, CompanyProcessStepStatusType.class);
    return companyProcessStepStatusTypes;
  }

  public Optional<CompanyProcessStepStatusType> getType(Long companyId, Long typeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("typeId", typeId);
    return sqlCache.get("processStepStatus.getType", params, CompanyProcessStepStatusType.class);
  }

  public void deleteType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", typeId);
    params.put("modifiedById", currentUser.getId());
    sqlCache.update("processStepStatus.deleteType", params);
  }

  public void updateType(CompanyProcessStepStatusType type) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", type.getCompanyId());
    params.put("id", type.getId());
    params.put("processStepStatusType", type.getProcessStepStatusType());
    params.put("processStepStatusTypeId", type.getProcessStepStatusTypeId());
    params.put("statusType", type.getProcessStepStatusType());
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("processStepStatus.updateType", params);
  }

  public Optional<CompanyProcessStepStatusType> insertType(CompanyProcessStepStatusType type) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", type.getCompanyId());
    params.put("id", type.getId());
    params.put("processStepStatusType", type.getProcessStepStatusType());
    params.put("processStepStatusTypeId", type.getProcessStepStatusTypeId());
    params.put("createdById", currentUser.getId());

    Long id = sqlCache.updateReturningId("processStepStatus.insertType", params, "id").longValue();

    return getType(type.getCompanyId(), id);
  }


  public void saveInitialProcessStepStatusType(Long companyProcessStepStatusTypeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", companyProcessStepStatusTypeId);
    params.put("companyId", currentUser.getCompanyId());
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("processStepStatus.saveInitialProcessStepStatusType", params);
  }

  public List<CompanyProcessStepStatusType> getAssignedToStep(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);

    List<CompanyProcessStepStatusType> results = sqlCache.query("processStepStatus.getAssignedToStep", params, CompanyProcessStepStatusType.class);
    return results;
  }

  public List<CompanyProcessStepStatusType> getCancelledAssignedToStep(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);

    List<CompanyProcessStepStatusType> results = sqlCache.query("processStepStatus.getCancelledAssignedToStep", params, CompanyProcessStepStatusType.class);
    return results;
  }

  public Optional<ProcessStepCompanyProcessStepStatusType> assignStatusToProcessStep(Long companyProcessStepStatusTypeId, Long processStepId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("companyProcessStepStatusTypeId", companyProcessStepStatusTypeId);
    params.put("createdById", currentUser.getId());

    Long id = sqlCache.updateReturningId("processStepStatus.assignStatusToProcessStep", params, "id").longValue();
    return getProcessStepCompanyProcessStepStatusType(id);
  }

  public Optional<ProcessStepCompanyProcessStepStatusType> getProcessStepCompanyProcessStepStatusType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProcessStepCompanyProcessStepStatusType> result = sqlCache.get("processStepStatus.getProcessStepCompanyProcessStepStatusType", params, ProcessStepCompanyProcessStepStatusType.class);
    return result;
  }

  public ResponseEntity deleteStatusFromProcessStep(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.getId());

    List<WorkQueueTypeProcessStepStatus> wqtUsingStatus = sqlCache.query("processStepStatus.statusInUseByWQT", params, WorkQueueTypeProcessStepStatus.class);

    if(wqtUsingStatus.isEmpty()) {
      sqlCache.update("processStepStatus.deleteStatusFromProcessStep", params);
      return ResponseEntity.ok().build();
    } else {
      return ResponseEntity.badRequest().body("Status is in use and cannot be deleted.");
    }
  }


}
