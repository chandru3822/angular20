package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ApiProject;
import com.albatross.api.v1.flow.services.Pagination;
import com.albatross.api.v1.flow.services.ProjectService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.hateoas.IanaLinkRelations;
import org.springframework.hateoas.server.ExposesResourceFor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static com.google.common.base.Preconditions.checkArgument;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@Slf4j
@RestController
@ExposesResourceFor(ApiProject.class)
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/processes/{processId}/projects")
public class ProjectController {
    private static final int DEFAULT_PAGE_SIZE = 50;

    @Autowired
    private ProjectService projectService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public Page<ApiProject> getProjectsForProcess(@PathVariable Long companyId,
                                                  @PathVariable Long processId) {
        return getProjectsForProcess_Paginated(companyId, processId, 0, DEFAULT_PAGE_SIZE);
    }

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE,
                params = {"page", "size"})
    public Page<ApiProject> getProjectsForProcess_Paginated(
            @PathVariable Long companyId,
            @PathVariable Long processId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "" + DEFAULT_PAGE_SIZE) int size) {
        checkArgument(size > 0, "size must be positive");
        checkArgument(size <= 1000, "size can't be too big");
        checkArgument(page >= 0, "page must be positive or zero");

        Pagination pagination = Pagination.fromPageSize(page, size);
        List<ApiProject> projects = projectService.getProjectsForProcess(companyId, processId, Optional.of(pagination))
                .stream()
                .map(ApiProject::from)
                .map(ProjectController::addLinks)
                .collect(Collectors.toList());
        Page<ApiProject> pageResult = new Page<>(projects);
        addPaginationLinks(pageResult, companyId, processId, pagination);
        return pageResult;
    }

    @RequestMapping(value = "/{projectId}",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiProject> getProject(@PathVariable Long companyId,
                                                 @PathVariable Long processId,
                                                 @PathVariable Long projectId) {
        return projectService.getProject(companyId, processId, projectId)
                .map(ApiProject::from)
                .map(ProjectController::addLinks)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    static ApiProject addLinks(ApiProject p) {
        // self link
        p.add(linkTo(methodOn(ProjectController.class).getProject(p.getCompanyIdentifier(),
                                                                  p.getProcessIdentifier(),
                                                                  p.getIdentifier()))
                .withSelfRel());

        // add process link
        p.add(linkTo(methodOn(ProcessController.class).getProcess(p.getCompanyIdentifier(), p.getProcessIdentifier()))
                .withRel("process"));

        // add company link
        p.add(linkTo(methodOn(CompanyController.class).getCompany(p.getCompanyIdentifier()))
                .withRel("company"));

        // add customer link
        p.add(linkTo(methodOn(CustomerController.class).getCustomer(p.getCompanyIdentifier(), p.getCustomerIdentifier()))
                .withRel("customer"));

        return p;
    }

    private void addPaginationLinks(Page<ApiProject> page,
                                    Long companyId, Long processId,
                                    Pagination pagination) {
        if (pagination.getPage() > 0) {
            page.add(linkTo(methodOn(ProjectController.class)
                    .getProjectsForProcess_Paginated(companyId,
                                                     processId,
                                                     pagination.getPage() - 1,
                                                     pagination.getSize()))
                .withRel(IanaLinkRelations.PREV));
        }

        if (page.size() == pagination.getSize()) {
            page.add(linkTo(methodOn(ProjectController.class)
                    .getProjectsForProcess_Paginated(companyId,
                                                     processId,
                                                     pagination.getPage() + 1,
                                                     pagination.getSize()))
                .withRel(IanaLinkRelations.NEXT));
        }
    }
}
