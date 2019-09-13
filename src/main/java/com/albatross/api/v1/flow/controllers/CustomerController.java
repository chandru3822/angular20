package com.albatross.api.v1.flow.controllers;


import java.util.List;

import com.albatross.api.v1.flow.model.Customer;
import com.albatross.api.v1.flow.model.Project;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomerService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/customer")
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping(value="/search", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Page<Customer>> searchCustomers(@RequestParam String query,Pageable pageable) {
        return new ResponseEntity<>(customerService.searchCustomers(query, pageable), HttpStatus.OK);
    }

    @GetMapping(value = "/exportCustomers", produces = "text/csv")
    public ResponseEntity exportCustomerList(@PathVariable Long companyId,
                                             @RequestParam String query) {
        return customerService.exportCustomers(companyId, query);
    }

    @GetMapping(value = "/{customerId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public Customer getCustomer(@PathVariable Long customerId) {
        return customerService.getCustomer(customerId);
    }

    @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
    public Customer updateCustomer(@RequestBody Customer customer) {
        return customerService.updateCustomer(customer);
    }

    @PostMapping(value = "/updateOwner", produces = MediaType.APPLICATION_JSON_VALUE)
    public void updateOwner(@RequestBody User user) {
        customerService.updateOwner(user);
    }

    @GetMapping(value = "/{customerId}/project", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Project> getCustomerProjects(@PathVariable Long customerId) {
        return new ResponseEntity<>(new Project(), HttpStatus.OK);
    }

    @GetMapping(value = "/project/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Customer> getCustomerByProjectId(@PathVariable Long projectId) {
      return new ResponseEntity<>(customerService.getCustomerByProjectId(projectId), HttpStatus.OK);
    }

    @GetMapping(value = "/owners", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getOwners() {
      return customerService.getOwnersForCustomer();
    }
}
