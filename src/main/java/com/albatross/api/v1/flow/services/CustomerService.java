package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Customer;
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
public class CustomerService {

  private final SqlCache sqlCache;

  public List<Customer> getCustomers(Long companyId) {
    return sqlCache.query("customer.getAllByCompany", ImmutableMap.of("companyId", companyId), Customer.class);
  }

  public Optional<Customer> getCustomer(Long customerId) {
    return sqlCache.get("customer.getById", ImmutableMap.of("customerId", customerId), Customer.class);
  }
}
