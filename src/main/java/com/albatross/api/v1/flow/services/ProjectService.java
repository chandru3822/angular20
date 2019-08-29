package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Project;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectService {

  private final SqlCache sqlCache;

  public List<Project> getProjectsForProcess(Long companyId, Long processId) {
    return sqlCache.query("project.getAllForCompanyProcess", ImmutableMap.of("companyId", companyId, "processId", processId), Project.class);
  }

  public Optional<Project> getProject(Long companyId, Long processId, Long projectId) {
    return sqlCache.get("project.get",
      ImmutableMap.of("companyId", companyId,
      "processId", processId,
      "projectId", projectId),
      Project.class);
  }

  public List<Project> getProjectsForCustomer(Long companyId, Long customerId) {
    return sqlCache.query("project.getAllForCustomer", ImmutableMap.of("companyId", companyId, "customerId", customerId), Project.class);
  }
}
