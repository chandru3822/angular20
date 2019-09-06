package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.CustomerType;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldValue;
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
    params.put("firstName", customer.getFirstName());
    params.put("lastName", customer.getLastName());
    params.put("street1", customer.getStreet1());
    params.put("city", customer.getCity());
    params.put("stateId", customer.getStateId());
    params.put("postalCode", customer.getPostalCode());
    params.put("countryId", customer.getCountryId());
    params.put("phone", customer.getPhone());
    params.put("email", customer.getEmail());
    params.put("mobile", customer.getMobile());
    params.put("companyId", customer.getCompanyId());
    params.put("ownerUserPositionId", customer.getOwnerUserPositionId());

    Long id;

    if(null != customer.getId()) {
      id = customer.getId();
      params.put("customerTypeId", customer.getCustomerTypeId());
      params.put("modifiedById", currentUser.getId());
      params.put("id", id);
      //add update when we add that to the UI
       sqlCache.update("customer.updateCustomer", params);
    } else {
      params.put("customerTypeId", CustomerType.LEAD.id);
      params.put("createdById", currentUser.getId());
      id = sqlCache.updateReturningId("customer.insertCustomer", params, "id").longValue();
    }

    handleSavingCustomFieldValues(customer.getCustomFieldGroups(), id);

    return getCustomer(id);
  }

  public Boolean fieldHasValue (CustomFieldValue cv) {
    return null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
        || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
  }

  public void handleSavingCustomFieldValues(List<CustomFieldGroup> groups, Long primaryId){
    User currentUser = securityService.getCurrentUser();
    for(CustomFieldGroup group : groups) {
      for(CustomFieldValue cfv : group.getCustomFieldValues()){
        if(fieldHasValue(cfv)) {
          HashMap<String, Object> params = new HashMap<>();
          params.put("dateValue", cfv.getDateValue());
          params.put("timestampValue", cfv.getTimestampValue());
          params.put("booleanValue", cfv.getBooleanValue());
          params.put("textValue", cfv.getTextValue());
          params.put("numericValue", cfv.getNumericValue());
          params.put("intValue", cfv.getIntValue());
          params.put("intArrayValue", cfv.getIntArrayValue());
          params.put("customerId", primaryId);
          params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

          if(null != cfv.getId()){
            params.put("id", cfv.getId());
            params.put("modifiedById", currentUser.getId());
            sqlCache.update("customFieldValues.updateCustomerCustomFieldValue", params);
          } else {
            params.put("createdById", currentUser.getId());
            sqlCache.update("customFieldValues.insertCustomerCustomFieldValue", params);
          }
        }
      }
    }
  }
}
