package com.albatross.api.v1.flow.services;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.CustomerType;
import com.albatross.api.v1.flow.enums.UserStatusType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.Collections2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.Customer;
import com.albatross.api.v1.flow.model.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class CustomerService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public Page<Customer> searchCustomers(String query, Pageable pageable) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    /* TODO: if we have to enable server-side sorting, this was my first attempt that kinda worked
    --  order by case :orderBy is not null
    --     when :orderBy = 'date_created' then c.date_created::text
    --     when :orderBy = 'first_name' then nullif(c.first_name) else c.date_created::text end desc nulls last
     */

    List<Customer> results = sqlCache.query("customer.searchCustomers", params, Customer.class);
    Integer count = sqlCache.queryForObject("customer.searchCustomerCount", params, Integer.class);

    Page<Customer> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }


  public ResponseEntity exportCustomers(String query) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);

    List<Customer> results = sqlCache.query("customer.exportCustomers", params, Customer.class);

    // set up CSV writing
    CsvMapper mapper = new CsvMapper();
    CsvSchema schema = mapper.typedSchemaFor(CustomerExportTemplate.class).withHeader();
    ObjectWriter writer = mapper.writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    // get customer deets and write to CSV
    try (SequenceWriter outToBuffer = writer.writeValues(buffer)) {
      // first, get deets
      Collection<CustomerExportTemplate> details = Collections2.transform(
          results,
          CustomerExportTemplate::from);

      // next, write them to a buffer so we can identify errors before writing across the network
      outToBuffer.writeAll(details);
      outToBuffer.flush();

      // finally, write to network because no errors were encountered
      return ResponseEntity.ok(buffer.toString(StandardCharsets.UTF_8));
    } catch (IOException e) {
      log.error("Encountered error while writing closer incentive export to CSV", e);
      return ResponseEntity.status(500)
          .body("Encountered error while writing closer incentive export to CSV");
    }
  }

  public Customer getCustomer(Long customerId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("customerId", customerId);
    Optional<Customer> result = sqlCache.get("customer.getById", params, Customer.class);
    return result.orElse(null);
  }

  public Customer getCustomerByProjectId(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    Optional<Customer> result = sqlCache.get("customer.getByProjectId", params, Customer.class);
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

  public void updateOwner(User user) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ownerUserPositionId", 7);
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("customer.updateOwner", params);
  }

  public List<User> getOwnersForCustomer() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Long> statusIds = new ArrayList<>();
    statusIds.add(UserStatusType.ACTIVE.id);
    statusIds.add(UserStatusType.PENDING_TERMINATION.id);

    params.put("statusIds", statusIds);
    List<User> results = sqlCache.query("customer.getOwners", params, User.class);
    return results;
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
