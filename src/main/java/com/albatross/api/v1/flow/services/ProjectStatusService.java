package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.ProjectStatusTypeController;
import com.albatross.api.v1.flow.model.CompanyProjectStatusType;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.project.CompanyProjectStatusFieldAssignment;
import com.albatross.api.v1.flow.model.project.ProjectStatusType;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProjectStatus;
import com.albatross.api.v1.flow.queries.ProjectQuery;
import com.albatross.api.v1.flow.queries.ProjectStatusQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProjectStatusService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public CompanyProjectStatusType getDefaultCompanyProjectStatusType(Long companyId) {
    return sqlCache
      .getBySql(
        ProjectStatusQuery.getDefaultProjectStatusTypeByCompanyId,
        Map.of("companyId", companyId),
        CompanyProjectStatusType.class)
      .orElse(null);
  }

  public List<WorkQueueTypeProjectStatus> getStatusesForWqt() {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(ProjectStatusQuery.getStatusesForWqt, params, WorkQueueTypeProjectStatus.class);
  }

  public List<ProjectStatusType> getCompanyProjectStatuses(Long projectId, Boolean excludeAttachments) {
    User currentUser = securityService.getCurrentUser();
    Long companyId = currentUser.getCompanyId();

    if (null != projectId) {
      // had to change this so that a parent looking at a child project could still see project statuses
      Map<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      companyId = sqlCache.queryForObjectBySql(ProjectQuery.getCompanyId, params, Long.class);
    }

    // NOTE: this returns COMPANY project statuses...as it should. but don't let it confuse you
    return sqlCache.queryBySql(
      ProjectStatusQuery.getCompanyStatuses,
      Map.of("companyId", companyId),
      ProjectStatusType.class);
  }

  public Optional<ProjectStatusType> getOneCompanyProjectStatusType(Long id) {
    return sqlCache.getBySql(
      ProjectStatusQuery.getOneCompanyStatus, Map.of("id", id), ProjectStatusType.class);
  }

  public void saveInitialProjectStatusType(Long companyProjectStatusTypeId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", companyProjectStatusTypeId);
    params.put("companyId", currentUser.getCompanyId());
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(ProjectStatusQuery.saveInitialProjectStatusType, params);
  }

  public Optional<ProjectStatusType> saveCompanyProjectStatus(ProjectStatusType status) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("rootProjectStatusTypeId", status.getProjectStatusTypeId());
    params.put("projectStatusType", status.getProjectStatusType());
    params.put("description", status.getDescription());
    params.put("isMilestone", status.getIsMilestone());
    params.put("iconTag", status.getIconTag());
    params.put("companyId", currentUser.getCompanyId());
    Long id;

    if (null != status.getId()) {
      id = status.getId();
      params.put("id", id);
      params.put("displayOrder", status.getDisplayOrder());
      sqlCache.updateBySql(ProjectStatusQuery.updateCompanyStatus, params);
    } else {
      id = sqlCache.updateBySqlReturningId(ProjectStatusQuery.insertCompanyStatus, params, "id").longValue();
    }

    // handle attachment

    return getOneCompanyProjectStatusType(id);
  }

  public void saveCompanyProjectStatuses(List<ProjectStatusType> statuses) {
    for (ProjectStatusType s : statuses) {
      saveCompanyProjectStatus(s);
    }
  }

  public List<ProjectStatusType> getProjectStatuses() {
    return sqlCache.queryBySql(ProjectStatusQuery.getStatuses, Collections.emptyMap(), ProjectStatusType.class);
  }

  public ResponseEntity<ProjectStatusTypeController.CannotDeleteProjectStatus> deleteCompanyProjectStatus(Long id) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("id", id);
    params.put("companyProjectStatusTypeId", id);

    Boolean statusInUseByProjects = sqlCache.queryForObjectBySql(ProjectStatusQuery.getStatusInUseByProjects, params, Boolean.class);
    Boolean statusInUseByActions = sqlCache.queryForObjectBySql(ProjectStatusQuery.getStatusInUseByActions, params, Boolean.class);
    Boolean statusInUseByEventRequirements = sqlCache.queryForObjectBySql(ProjectStatusQuery.getStatusInUseByPseRequirements, params, Boolean.class);
    Boolean statusInUseByProcessStepRequirements = sqlCache.queryForObjectBySql(ProjectStatusQuery.getStatusInUseByPsRequirements, params, Boolean.class);

    if (!statusInUseByProjects && !statusInUseByActions && !statusInUseByEventRequirements && !statusInUseByProcessStepRequirements) {
      sqlCache.updateBySql(ProjectStatusQuery.deleteCompanyStatus, params);
      return ResponseEntity.ok().build();
    } else {
      ProjectStatusTypeController.CannotDeleteProjectStatus cannotDelete = new ProjectStatusTypeController.CannotDeleteProjectStatus();
      cannotDelete.setStatusInUseByProjects(statusInUseByProjects);
      cannotDelete.setStatusInUseByActions(statusInUseByActions);
      cannotDelete.setStatusInUseByEventRequirements(statusInUseByEventRequirements);
      cannotDelete.setStatusInUseByProcessStepRequirements(statusInUseByProcessStepRequirements);
      return ResponseEntity.badRequest().body(cannotDelete);
    }
  }

  //data view field stuff for milestones
  public Optional<CompanyProjectStatusFieldAssignment> addFieldToCompanyProjectStatus(Long cpstId, CompanyProjectStatusFieldAssignment field) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("companyProjectStatusTypeId", cpstId);
    params.put("dataViewFieldConfigId", field.getDataViewFieldConfigId());
    params.put("dataViewChildFieldConfigId", field.getDataViewChildFieldConfigId());

    Long id = sqlCache.updateBySqlReturningId(ProjectStatusQuery.insertStatusFieldAssignment, params, "id").longValue();

    return getOneCompanyProjectStatusFieldAssignment(id);
  }

  public List<CompanyProjectStatusFieldAssignment> getFieldsForCompanyProjectStatus(Long cpstId) {
    Map<String, Object> params = new HashMap<>();
    params.put("companyProjectStatusTypeId", cpstId);

    List<CompanyProjectStatusFieldAssignment> results = sqlCache.queryBySql(ProjectStatusQuery.getAssignedStatusFields, params, CompanyProjectStatusFieldAssignment.class);

    return results;
  }

  public Optional<CompanyProjectStatusFieldAssignment> getOneCompanyProjectStatusFieldAssignment(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<CompanyProjectStatusFieldAssignment> result = sqlCache.getBySql(ProjectStatusQuery.getStatusFieldAssignment, params, CompanyProjectStatusFieldAssignment.class);

    return result;
  }

  public void saveFieldsOrder(Long cpstId, List<CompanyProjectStatusFieldAssignment> fields) {
    for (CompanyProjectStatusFieldAssignment s : fields) {
      saveFieldOrder(s);
    }
  }

  public void saveFieldOrder(CompanyProjectStatusFieldAssignment field) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("id", field.getId());
    params.put("displayOrder", field.getDisplayOrder());

    sqlCache.updateBySql(ProjectStatusQuery.saveStatusFieldAssignmentOrder, params);
  }

  public void archiveField(Long fieldId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("id", fieldId);

    sqlCache.updateBySql(ProjectStatusQuery.archiveField, params);
  }
}
