package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.Customer;
import com.albatross.api.v1.flow.model.Project;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/{companyId}/customer")
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<Customer>> getCustomersForCompany(@PathVariable Long companyId) {
      return new ResponseEntity<>(customerService.getCustomers(companyId), HttpStatus.OK);
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
    public ResponseEntity<Project> getCustomerProjects(@PathVariable Long companyId, @PathVariable Long customerId) {
      return new ResponseEntity<>(new Project(), HttpStatus.OK);
    }

    @GetMapping(value = "/owners", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getOwners(@PathVariable Long companyId) {
      return customerService.getOwners(companyId);
    }
}
