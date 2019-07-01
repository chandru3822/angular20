package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ApiCompany;
import com.albatross.api.v1.flow.services.CompanyService;
import com.albatross.api.v1.flow.services.Pagination;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.hateoas.IanaLinkRelations;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

import static com.google.common.base.Preconditions.checkArgument;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;


@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/companies")
public class CompanyController {
    private static final int DEFAULT_PAGE_SIZE = 50;

    @Autowired
    private CompanyService companyService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public Page<ApiCompany> getAllCompanies() {
        return getAllCompanies_Paginated(0, DEFAULT_PAGE_SIZE);
    }

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE,
            params = {"page", "size"})
    public Page<ApiCompany> getAllCompanies_Paginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "" + DEFAULT_PAGE_SIZE) int size) {
        checkArgument(size > 0, "size must be positive");
        checkArgument(size <= 1000, "size can't be too big");
        checkArgument(page >= 0, "page must be positive or zero");

        Pagination pagination = Pagination.fromPageSize(page, size);
        List<ApiCompany> companies = companyService.getCompanies(pagination)
                .stream()
                .map(ApiCompany::from)
                .map(CompanyController::addLinks)
                .collect(Collectors.toList());
        Page<ApiCompany> result = new Page<>(companies);
        addPaginationLinks(result, pagination);
        return result;
    }

    @RequestMapping(value = "/{id}",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiCompany> getCompany(@PathVariable Long id) {
        return companyService.getCompany(id)
                             .map(ApiCompany::from)
                             .map(CompanyController::addLinks)
                             .map(ResponseEntity::ok)
                             .orElse(ResponseEntity.notFound().build());
    }

    private static ApiCompany addLinks(ApiCompany c) {
        // self link
        c.add(linkTo(methodOn(CompanyController.class).getCompany(c.getIdentifier())).withSelfRel());

        // add processes link
        c.add(linkTo(methodOn(ProcessController.class).getProcessesForCompany(c.getIdentifier()))
                .withRel("processes"));

        // add customers link
        c.add(linkTo(methodOn(CustomerController.class).getCustomersForCompany(c.getIdentifier()))
                .withRel("customers"));

        return c;
    }

    private void addPaginationLinks(Page<ApiCompany> page,
                                    Pagination pagination) {
        if (pagination.getPage() > 0) {
            page.add(linkTo(methodOn(CompanyController.class)
                    .getAllCompanies_Paginated(pagination.getPage() - 1,
                                               pagination.getSize()))
                    .withRel(IanaLinkRelations.PREV));
        }

        if (page.size() == pagination.getSize()) {
            page.add(linkTo(methodOn(CompanyController.class)
                    .getAllCompanies_Paginated(pagination.getPage() + 1,
                                               pagination.getSize()))
                    .withRel(IanaLinkRelations.NEXT));
        }
    }
}
