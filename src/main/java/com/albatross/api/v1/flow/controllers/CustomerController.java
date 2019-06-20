package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.ApiCustomer;
import com.albatross.api.v1.flow.services.CustomerService;
import com.albatross.api.v1.flow.services.Pagination;
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
import java.util.stream.Collectors;

import static com.google.common.base.Preconditions.checkArgument;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@Slf4j
@RestController
@ExposesResourceFor(ApiCustomer.class)
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/customers")
public class CustomerController {
    private static final int DEFAULT_PAGE_SIZE = 50;

    @Autowired
    private CustomerService customerService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public Page<ApiCustomer> getCustomersForCompany(@PathVariable Long companyId) {
        return getCustomersForCompany_Paginated(companyId, 0, DEFAULT_PAGE_SIZE);
    }

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE,
            params = {"page", "size"})
    public Page<ApiCustomer> getCustomersForCompany_Paginated(
            @PathVariable Long companyId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "" + DEFAULT_PAGE_SIZE) int size) {
        checkArgument(size > 0, "size must be positive");
        checkArgument(size <= 1000, "size can't be too big");
        checkArgument(page >= 0, "page must be positive or zero");

        Pagination pagination = Pagination.fromPageSize(page, size);
        List<ApiCustomer> projects = customerService.getCustomers(companyId, pagination)
                .stream()
                .map(ApiCustomer::from)
                .map(CustomerController::addLinks)
                .collect(Collectors.toList());
        Page<ApiCustomer> pageResult = new Page<>(projects);
        addPaginationLinks(pageResult, companyId, pagination);
        return pageResult;
    }

    @RequestMapping(value = "/{customerId}",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiCustomer> getCustomer(@PathVariable Long companyId,
                                                   @PathVariable Long customerId) {
        return customerService.getCustomer(companyId, customerId)
                .map(ApiCustomer::from)
                .map(CustomerController::addLinks)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    private static ApiCustomer addLinks(ApiCustomer c) {
        // self link
        c.add(linkTo(methodOn(CustomerController.class).getCustomer(c.getCompanyIdentifier(),
                                                                    c.getIdentifier()))
                .withSelfRel());

        // add company link
        c.add(linkTo(methodOn(CompanyController.class).getCompany(c.getCompanyIdentifier()))
                .withRel("company"));

        // add projects link
        c.add(linkTo(methodOn(CompanyDataSearchController.class).getProjectsForCustomer(c.getCompanyIdentifier(), c.getIdentifier()))
                .withRel("projects"));

        return c;
    }

    private void addPaginationLinks(Page<ApiCustomer> page,
                                    Long companyId,
                                    Pagination pagination) {
        if (pagination.getPage() > 0) {
            page.add(linkTo(methodOn(CustomerController.class)
                    .getCustomersForCompany_Paginated(companyId,
                            pagination.getPage() - 1,
                            pagination.getSize()))
                    .withRel(IanaLinkRelations.PREV));
        }

        if (page.size() == pagination.getSize()) {
            page.add(linkTo(methodOn(CustomerController.class)
                    .getCustomersForCompany_Paginated(companyId,
                            pagination.getPage() + 1,
                            pagination.getSize()))
                    .withRel(IanaLinkRelations.NEXT));
        }
    }
}
