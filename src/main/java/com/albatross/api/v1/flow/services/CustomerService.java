package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Customer;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class CustomerService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<Customer> getCustomers(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);

    List<Customer> results = sqlCache.query("customer.getAllByCompany", params, Customer.class);
    return results;
  }

  public Customer getCustomer(Long customerId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("customerId", customerId);
    Optional<Customer> result = sqlCache.get("customer.getById", params, Customer.class);
    return result.orElse(null);
  }

  public Customer updateCustomer(Customer customer) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", customer.getCompanyId());
    params.put("firstName", customer.getFirstName());
    params.put("lastName", customer.getLastName());
    params.put("email", customer.getEmail());
    params.put("phone", customer.getPhone());
    params.put("mobile", customer.getMobile());
    params.put("street1", customer.getStreet1());
    params.put("city", customer.getCity());
    params.put("stateId", customer.getStateId());
    params.put("postalCode", customer.getPostalCode());
    params.put("countryId", customer.getCountryId());
    //not sure what this is yet
    params.put("customerTypeId", customer.getCustomerTypeId());

    Long id;

    if(null != customer.getId()) {
      id = customer.getId();
      params.put("modifiedById", currentUser.getId());
      params.put("id", id);
      //add update when we add that to the UI
       sqlCache.update("customer.updateCustomer", params);
    } else {
      params.put("createdById", currentUser.getId());
      id = sqlCache.updateReturningId("customer.insertCustomer", params, "id").longValue();
    }

    return getCustomer(id);
  }
}
