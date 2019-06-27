package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.services.dto.DtoProject;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Optional;

@Slf4j
@Service
public class ProjectService {
    @Autowired
    private SqlCache sqlCache;

    private static final int DEFAULT_PAGE_SIZE = 50;

    public Collection<DtoProject> getProjectsForProcess(Long companyId, Long processId,
                                                        Optional<Pagination> requestedPagination) {
        final Pagination defaultPagination = Pagination.fromOffsetLimit(0, DEFAULT_PAGE_SIZE);

        Pagination pagination = requestedPagination.orElse(defaultPagination);

        return sqlCache.query("project.getAllForCompanyProcess",
                ImmutableMap.of("companyId", companyId,
                                "processId", processId,
                                "offset", pagination.getStartOffset(),
                                "limit", pagination.getSize()),
                DtoProject.class);
    }

    public Optional<DtoProject> getProject(Long companyId, Long processId, Long projectId) {
        return sqlCache.get("project.get",
                ImmutableMap.of("companyId", companyId,
                                "processId", processId,
                                "projectId", projectId),
                DtoProject.class);
    }

    public Collection<DtoProject> getProjectsForCustomer(Long companyId, Long customerId,
                                                        Optional<Pagination> requestedPagination) {
        final Pagination defaultPagination = Pagination.fromOffsetLimit(0, DEFAULT_PAGE_SIZE);

        Pagination pagination = requestedPagination.orElse(defaultPagination);

        return sqlCache.query("project.getAllForCustomer",
                ImmutableMap.of("companyId", companyId,
                        "customerId", customerId,
                        "offset", pagination.getStartOffset(),
                        "limit", pagination.getSize()),
                DtoProject.class);
    }
}
