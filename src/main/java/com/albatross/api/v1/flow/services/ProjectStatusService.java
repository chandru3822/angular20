package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.ApiException;
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
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProjectStatusService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final SqlArrayService sqlArrayService;
  private final ObjectMapper om;

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

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);

    if (projectId != null) {
      params.put("projectId", projectId);

      // had to change this so that a parent looking at a child project could still see project statuses
      companyId = sqlCache.queryForObjectBySql(ProjectQuery.getCompanyId, params, Long.class);
      params.put("companyId", companyId);

      return sqlCache.queryBySql(
        ProjectStatusQuery.getCompanyStatusesForProjectId,
        params, new ProjectStatusTypeMapper<>(ProjectStatusType.class, om));
    }

    // NOTE: this returns COMPANY project statuses...as it should. but don't let it confuse you
    return sqlCache.queryBySql(
      ProjectStatusQuery.getCompanyStatuses,
      params, new ProjectStatusTypeMapper<>(ProjectStatusType.class, om));
  }

  public List<ProjectStatusType> getCompanyProjectStatusesByObjectCategory(Long objectCategoryId){
    User currentUser = securityService.getCurrentUser();
    Long companyId = currentUser.getCompanyId();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("objectCategoryId",objectCategoryId);

    return sqlCache.queryBySql(
      ProjectStatusQuery.getCompanyStatusesForObjectCategory,
      params, new ProjectStatusTypeMapper<>(ProjectStatusType.class, om));
  }

  public Optional<ProjectStatusType> getOneCompanyProjectStatusType(Long id) {
    return sqlCache.getBySql(
      ProjectStatusQuery.getOneCompanyStatus, Map.of("id", id), new ProjectStatusTypeMapper<>(ProjectStatusType.class, om));
  }

  public Optional<ProjectStatusType> getOneCompanyObjectCategoryProjectStatusType(Long cpstId,Long objectCategoryId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("cpstId",cpstId);
    params.put("objectCategoryId",objectCategoryId);
    return sqlCache.getBySql(
      ProjectStatusQuery.getOneCompanyStatusOfObjectCategory, params, new ProjectStatusTypeMapper<>(ProjectStatusType.class, om));
  }

  public void saveInitialProjectStatusType(Long companyProjectStatusTypeId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", companyProjectStatusTypeId);
    params.put("companyId", currentUser.getCompanyId());
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(ProjectStatusQuery.saveInitialProjectStatusType, params);
  }

  public List<ProjectStatusType> updateCompanyProjectDisplayOrder(List<ProjectStatusType> statuses) {
    List<ProjectStatusType> projectStatusTypes = new ArrayList<>();
    for (ProjectStatusType s : statuses) {
      Optional<ProjectStatusType> projectStatusTypeOptional = updateStatusOfObjectCategory(s);
      projectStatusTypeOptional.ifPresent(projectStatusTypes::add);
    }
    return projectStatusTypes;
  }


  public Optional<ProjectStatusType> updateStatusOfObjectCategory(ProjectStatusType status){
        User currentUser = securityService.getCurrentUser();
        Map<String, Object> params = new HashMap<>();
        params.put("currentUserId", currentUser.trueUserId());
        params.put("companyProjectStatusTypeId", status.getId());
        params.put("objectCategoryId", status.getObjectCategoryIds().getFirst());
        params.put("displayOrder", status.getDisplayOrder());
        sqlCache.updateBySql(ProjectStatusQuery.updateCompanyStatusOnDragAndDrop, params);

        return getOneCompanyObjectCategoryProjectStatusType(status.getId(),status.getObjectCategoryIds().getFirst());

  }

  public Optional<ProjectStatusType> saveCompanyProjectStatus(ProjectStatusType status) {
    try {
      User currentUser = securityService.getCurrentUser();
      Map<String, Object> params = new HashMap<>();
      params.put("currentUserId", currentUser.trueUserId());
      params.put("rootProjectStatusTypeId", status.getProjectStatusTypeId());
      params.put("projectStatusType", status.getProjectStatusType());
      params.put("description", status.getDescription());
      params.put("isMilestone", status.getIsMilestone());
      params.put("iconTag", status.getIconTag());
      params.put("companyId", currentUser.getCompanyId());
      params.put("objectCategoryIds", sqlArrayService.createSqlArrayOfType("int", status.getObjectCategoryIds()));

      Long id;

      if (null != status.getId()) {
        id = status.getId();
        params.put("id", id);
        params.put("displayOrder", status.getDisplayOrder());
        sqlCache.updateBySql(ProjectStatusQuery.updateCompanyStatus, params);
      } else {
        id = sqlCache.queryForObjectBySql(ProjectStatusQuery.insertCompanyStatus, params, Long.class);
      }

      // handle attachment
      return getOneCompanyProjectStatusType(id);
    } catch (SQLException e) {
      throw new ApiException(e);
    }
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

    return sqlCache.queryBySql(ProjectStatusQuery.getAssignedStatusFields, params, CompanyProjectStatusFieldAssignment.class);
  }

  public Optional<CompanyProjectStatusFieldAssignment> getOneCompanyProjectStatusFieldAssignment(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(ProjectStatusQuery.getStatusFieldAssignment, params, CompanyProjectStatusFieldAssignment.class);
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

  public static class ProjectStatusTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProjectStatusTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Long>> listTypeReference = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "objectCategoryIds",
        new JsonCollectionDeserializer<>(listTypeReference, objectMapper));
    }
  }
}
