package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.Collections2;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
public class UserService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public Page<User> searchUsers(UserSearch search, Pageable pageable) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", search.getSearch());
    params.put("firstName", search.getFirstName());
    params.put("lastName", search.getLastName());
    params.put("email", search.getEmail());
    params.put("phone", search.getPhone());
    params.put("statuses", search.getStatuses());
    params.put("positions", search.getPositions());
    params.put("orgs", search.getOrgs());
    params.put("primaryFlag", search.getPrimaryFlag());
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<User> results = sqlCache.query("user.searchUsers", params, new UserMapper<>(User.class, om));
    Integer count = sqlCache.queryForObject("user.searchUserCount", params, Integer.class);

    Page<User> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }

  public ResponseEntity exportUsers(UserSearch search) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", search.getSearch());
    params.put("firstName", search.getFirstName());
    params.put("lastName", search.getLastName());
    params.put("email", search.getEmail());
    params.put("phone", search.getPhone());
    params.put("statuses", search.getStatuses());
    params.put("positions", search.getPositions());

    List<User> results = sqlCache.query("user.exportUsers", params, User.class);

    // set up CSV writing
    CsvMapper mapper = new CsvMapper();
    CsvSchema schema = mapper.typedSchemaFor(UserExportTemplate.class).withHeader();
    ObjectWriter writer = mapper.writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    // get user deets and write to CSV
    try (SequenceWriter outToBuffer = writer.writeValues(buffer)) {
      // first, get deets
      Collection<UserExportTemplate> details = Collections2.transform(
          results,
          UserExportTemplate::from);

      // next, write them to a buffer so we can identify errors before writing across the network
      outToBuffer.writeAll(details);
      outToBuffer.flush();

      // finally, write to network because no errors were encountered
      return ResponseEntity.ok(buffer.toString(StandardCharsets.UTF_8));
    } catch (IOException e) {
      log.error("Encountered error while writing user export to CSV", e);
      return ResponseEntity.status(500)
          .body("Encountered error while writing user export to CSV");
    }
  }

  public boolean emailExists(String email, Long userId) {
    //using ILIKE to prevent duplicates with different casing
    HashMap<String, Object> params = new HashMap<>();
    params.put("email", email);
    params.put("userId", userId);

    List<User> results = sqlCache.query("user.checkEmailExists", params, User.class);
    return null != results && !results.isEmpty();
  }

  public ResponseEntity saveUser(User user) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", user.getFirstName());
    params.put("lastName", user.getLastName());
    params.put("phone", user.getPhoneNumber());
    params.put("email", user.getEmail());
    params.put("schedulable", user.getSchedulable() != null ? user.getSchedulable() : false);
    params.put("companyId", currentUser.getCompanyId());

    Long id;

    if(null != user.getId()) {
      id = user.getId();
      params.put("modifiedById", currentUser.getId());
      params.put("id", id);
      sqlCache.update("user.updateUser", params);
      //todo: handle saving user_companies here as well
      handleSavingUserCompanies(user.getCompanies(), user.getId());
    } else {
      params.put("createdById", currentUser.getId());
      //for now we are inserting new users with the same email and username. maybe we will change that later and let them enter it here
      id = sqlCache.updateReturningId("user.insertUser", params, "id").longValue();
      //insert a row into user_company
      params.put("id", id);
      params.put("isDefault", true);
      sqlCache.update("user.insertUserCompany", params);
    }

    handleSavingCustomFieldValues(user.getCustomFieldGroups(), id);

    return getUser(id);
  }

  public ResponseEntity getUser(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<User> result = sqlCache.get("user.getOne", params, new UserMapper<>(User.class, om));

    User currentUser = securityService.getCurrentUser();

    if(result.isPresent() && !currentUser.getCompanyId().equals(result.get().getCompanyId())) {
      return ResponseEntity.badRequest().body("Cannot Access User");
    } else {
      return ResponseEntity.ok(result);
    }
  }

  public List<User> getSchedulingUsers(Long stateId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    params.put("companyId", currentUser.getCompanyId());
    List<User> results = sqlCache.query("user.getSchedulingUsers", params, User.class);
    return results;
  }


  public Boolean fieldHasValue (CustomFieldValue cv) {
    return null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
        || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
  }

  public void handleSavingUserCompanies(List<Company> companies, Long userId){
    log.info("COMPANIA!!!!!!!!!!! {}", companies);
    //archive any existing rows that are no longer there
    List<Long> companyIds = companies.stream().map(Company::getId).collect(Collectors.toList());
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyIds", companyIds);
    sqlCache.update("user.archiveUserCompanies", params);

    for(Company company: companies) {
      //upsert any new/existing rows
      HashMap<String, Object> vars = new HashMap<>();
      vars.put("userId", userId);
      vars.put("companyId", company.getId());
      sqlCache.update("user.upsertUserCompany", vars);
    }
  }

  public void handleSavingCustomFieldValues(List<CustomFieldGroup> groups, Long primaryId){
    User currentUser = securityService.getCurrentUser();
    for(CustomFieldGroup group : groups) {
      for(CustomFieldValue cfv : group.getCustomFieldValues()){
        //todo: only save if something changed
        if(fieldHasValue(cfv)) {
          HashMap<String, Object> params = new HashMap<>();
          params.put("dateValue", cfv.getDateValue());
          params.put("timestampValue", cfv.getTimestampValue());
          params.put("booleanValue", cfv.getBooleanValue());
          params.put("textValue", cfv.getTextValue());
          params.put("numericValue", cfv.getNumericValue());
          params.put("intValue", cfv.getIntValue());
          params.put("intArrayValue", cfv.getIntArrayValue());
          params.put("userId", primaryId);
          params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

          if(null != cfv.getId()){
            params.put("id", cfv.getId());
            params.put("modifiedById", currentUser.getId());
            sqlCache.update("customFieldValues.updateUserCustomFieldValue", params);
          } else {
            params.put("createdById", currentUser.getId());
            sqlCache.update("customFieldValues.insertUserCustomFieldValue", params);
          }
        }
      }
    }
  }

  public User findByUsernameIgnoreCase(String username, Long userId) {
    // i updated this to find by username or by userId so that we can call the same function on login AND on change context
    HashMap<String, Object> params = new HashMap<>();
    params.put("username", username);
    params.put("userId", userId);
    Optional<User> user = sqlCache.get("user.findByUsernameIgnoreCase", params, new UserMapper<>(User.class, om));
    return user.orElse(null);
  }

  public User findByUserUuid(UUID uuid) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("uuid", uuid);
    Optional<User> user = sqlCache.get("user.findByUserUuid", params, User.class);
    return user.orElse(null);
  }

  public User findUserById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<User> user = sqlCache.get("user.findUserById", params, User.class);
    return user.orElse(null);
  }

  public List<UserStatusType> getUserStatuses() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<UserStatusType> results = sqlCache.query("user.getUserStatuses", params, UserStatusType.class);
    return results;
  }

  public ResponseEntity changeContextAdmin(Long companyId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("companyId", companyId);

    sqlCache.update("user.updateAdminDefault", params);

    return ResponseEntity.ok(findByUsernameIgnoreCase(null, user.getId()));
  }

  public ResponseEntity changeContext(Long companyId) {
    User user = securityService.getCurrentUser();
    Boolean match = false;
    // get list of companies the user has access to
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    List<Company> companies = sqlCache.query("company.getCompaniesAssignedToUser", params, Company.class);

    // verify they have access to the company id that was sent in
    for(Company c : companies) {
      if(c.getId().equals(companyId)) {
        match = true;
        break;
      }
    }

    // if valid, update the default for the user and return full user details including permissions
    if(match) {
      params.put("companyId", companyId);
      sqlCache.update("user.updateDefault", params);

      return ResponseEntity.ok(findByUsernameIgnoreCase(null, user.getId()));
    } else {
      return ResponseEntity.badRequest().body("Invalid Company For User");
    }
  }

  public static class UserMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public UserMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<UserPermission>> userPermissionRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "permissions",
          new JsonCollectionDeserializer(userPermissionRef, objectMapper));

      TypeReference<List<UserOrgHierarchy>> userOrgHierarchyRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "hierarchy",
          new JsonCollectionDeserializer(userOrgHierarchyRef, objectMapper));

      TypeReference<List<Company>> companiesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "companies",
          new JsonCollectionDeserializer(companiesRef, objectMapper));
    }
  }
}
