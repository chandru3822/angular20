package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Project;
import com.albatross.api.v1.flow.model.ProjectField;
import com.albatross.api.v1.flow.model.ProjectProcessStep;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectService {

  private final SqlCache sqlCache;

  public List<Project> getProjectsForProcess(Long companyId, Long processId) {
    return sqlCache.query("project.getAllForCompanyProcess", ImmutableMap.of("companyId", companyId, "processId", processId), Project.class);
  }

  public Optional<Project> getProject(Long projectId) {
    return sqlCache.get("project.get", ImmutableMap.of("projectId", projectId), Project.class);
  }

  public List<Project> getProjectsForCustomer(Long companyId, Long customerId) {
    return sqlCache.query("project.getAllForCustomer", ImmutableMap.of("companyId", companyId, "customerId", customerId), Project.class);
  }

  public List<ProjectProcessStep> getProcessStepsByProjectId(Long projectId) {
    return sqlCache.query("project.getProcessStepsByProjectId", ImmutableMap.of("projectId", projectId), ProjectProcessStep.class);
  }

  public List<ProjectField> getFieldsByProjectId(Long companyId, Long projectId) {
    ImmutableMap<String, Object> params = ImmutableMap.of("projectId", projectId, "companyId", companyId);
    return sqlCache.query("project.getFieldsByProjectId", params, ProjectField.class);
  }
}
