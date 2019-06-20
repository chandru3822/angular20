package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ApiProject;
import com.albatross.api.v1.flow.services.Pagination;
import com.albatross.api.v1.flow.services.ProjectService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.hateoas.IanaLinkRelations;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
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
@RequestMapping(value = "/api/v1/flow/companies/{companyId}")
public class CompanyDataSearchController {
    private static final int DEFAULT_PAGE_SIZE = 50;

    @Autowired
    private ProjectService projectService;

    @GetMapping(value = "/projects",
            produces = MediaType.APPLICATION_JSON_VALUE,
            params = {"customerId"})
    public Page<ApiProject> getProjectsForCustomer(@PathVariable Long companyId,
                                                   @RequestParam Long customerId) {
        return getProjectsForCustomer_Paginated(companyId, customerId,
                0, DEFAULT_PAGE_SIZE);
    }

    @GetMapping(value = "/projects",
            produces = MediaType.APPLICATION_JSON_VALUE,
            params = {"customerId", "page", "size"})
    public Page<ApiProject> getProjectsForCustomer_Paginated(@PathVariable Long companyId,
                                                             @RequestParam Long customerId,
                                                             @RequestParam(defaultValue = "0") int page,
                                                             @RequestParam(defaultValue = "" + DEFAULT_PAGE_SIZE) int size) {
        checkArgument(size > 0, "size must be positive");
        checkArgument(size <= 1000, "size can't be too big");
        checkArgument(page >= 0, "page must be positive or zero");

        Pagination pagination = Pagination.fromPageSize(page, size);
        List<ApiProject> projects = projectService.getProjectsForCustomer(companyId, customerId, Optional.of(pagination))
                .stream()
                .map(ApiProject::from)
                .map(ProjectController::addLinks)
                .collect(Collectors.toList());
        Page<ApiProject> pageResult = new Page<>(projects);

        // add pagination links
        if (pagination.getPage() > 0) {
            pageResult.add(linkTo(methodOn(CompanyDataSearchController.class)
                    .getProjectsForCustomer_Paginated(companyId,
                            customerId,
                        pagination.getPage() - 1,
                             pagination.getSize()))
                    .withRel(IanaLinkRelations.PREV));
        }

        if (pageResult.size() == pagination.getSize()) {
            pageResult.add(linkTo(methodOn(CompanyDataSearchController.class)
                    .getProjectsForCustomer_Paginated(companyId,
                            customerId,
                            pagination.getPage() + 1,
                            pagination.getSize()))
                    .withRel(IanaLinkRelations.NEXT));
        }

        return pageResult;
    }
}
