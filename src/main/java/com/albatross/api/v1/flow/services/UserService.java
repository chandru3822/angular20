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
import org.springframework.security.crypto.bcrypt.BCrypt;
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

  public void saveForgotPasswordFields(User user, Boolean updatePassword) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", user.getId());
    params.put("uuid", user.getUuid());
    params.put("expiryDate", user.getExpiryDate());

    sqlCache.update("user.saveForgotPasswordFields", params);
    if(updatePassword) {
      params.put("password", user.getPassword());
      sqlCache.update("user.saveUserPassword", params);
    }
  }

  public Optional<User> saveUser(User user) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", user.getFirstName());
    params.put("lastName", user.getLastName());
    params.put("phone", user.getPhoneNumber());
    params.put("email", user.getEmail());
    params.put("companyId", currentUser.getCompanyId());

    Long id;

    if(null != user.getId()) {
      id = user.getId();
      params.put("modifiedById", currentUser.getId());
      params.put("id", id);
      sqlCache.update("user.updateUser", params);
      //save user status
      saveUserStatus(id, user.getCompanyUserStatusTypeId());
      //save user companies
      handleSavingUserCompanies(user.getCompanies(), user.getId());
    } else {
      //get the default password
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("id", currentUser.getCompanyId());
      Optional<Company> c = sqlCache.get("company.getById", p2, Company.class);
      params.put("createdById", currentUser.getId());
      String newPwd = null;
      if(c.isPresent()) {
        newPwd = BCrypt.hashpw(c.get().getDefaultPassword(), BCrypt.gensalt(10));
      }
      params.put("defaultPassword", newPwd);
      //for now we are inserting new users with the same email and username. maybe we will change that later and let them enter it here
      id = sqlCache.updateReturningId("user.insertUser", params, "id").longValue();
      //insert a row into user_company
      params.put("id", id);
      params.put("isDefault", true);
      sqlCache.update("user.insertUserCompany", params);
      //insert a row into user_status
      saveUserStatus(id, user.getCompanyUserStatusTypeId());
    }



    return getUser(id);
  }

  public Optional<User> getUser(Long id) {
    User currentUser = securityService.getCurrentUser();
    // using currentUser.companyId validates that the user requesting the info can actually access this user...i think
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", currentUser.getCompanyId());
    Optional<User> result = sqlCache.get("user.getOne", params, new UserMapper<>(User.class, om));

    return result;
  }

  public List<User> getSchedulingUsers(Long stateId, Boolean isSchedulingTool) {
    //i had to change this to return user positions so that when filtering by position in the scheduling tool we have the data
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("isSchedulingTool", isSchedulingTool);

    List<User> results = sqlCache.query("user.getSchedulingUsers", params, new UserMapper<>(User.class, om));
    return results;
  }

  public void handleSavingUserCompanies(List<Company> companies, Long userId){
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

  public User findByUsernameIgnoreCase(String username, Long userId) {
    // i updated this to find by username or by userId so that we can call the same function on login AND on change context
    HashMap<String, Object> params = new HashMap<>();
    params.put("username", username);
    params.put("userId", userId);
    Optional<User> user = sqlCache.get("user.findByUsernameIgnoreCase", params, new UserMapper<>(User.class, om));
    return user.orElse(null);
  }

  public User findByUsernameOrEmailIgnoreCase(String usernameOrEmail) {
    // for forgot password they need to be able to enter username or email. this will find them either way
    HashMap<String, Object> params = new HashMap<>();
    params.put("usernameOrEmail", usernameOrEmail);
    Optional<User> user = sqlCache.get("user.findByUsernameOrEmailIgnoreCase", params, new UserMapper<>(User.class, om));
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

  public List<CompanyUserStatusType> getCompanyUserStatuses() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CompanyUserStatusType> results = sqlCache.query("user.getCompanyUserStatuses", params, CompanyUserStatusType.class);
    return results;
  }

  public void saveUserStatus(Long userId, Long companyUserStatusTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);
    params.put("companyUserStatusTypeId", companyUserStatusTypeId);

    sqlCache.update("user.saveUserStatus", params);
  }

  public ResponseEntity changeContext(Long companyId) {
    User user = securityService.getCurrentUser();
    return user.getHighestCompanyId() == 1L ? changeContextAdmin(companyId) : changeContextNonAdmin(companyId);
  }

  public ResponseEntity changeContextAdmin(Long companyId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("companyId", companyId);

    sqlCache.update("user.updateAdminDefault", params);

    return ResponseEntity.ok(findByUsernameIgnoreCase(null, user.getId()));
  }

  public ResponseEntity changeContextNonAdmin(Long companyId) {
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

  public ResponseEntity getLoggedInUser() {
    User user = securityService.getCurrentUser();

    if(null != user) {
      User response = findByUsernameIgnoreCase(null, user.getId());

      List<FeatureAccessControl> results = securityService.getUserFeatureAccess(user.getId(), user.getCompanyId());
      response.setFeatureAccess(results);
      return ResponseEntity.ok(response);
    } else {
      return ResponseEntity.badRequest().body("No user found");
    }
  }

  public String updatePassword(PasswordResetRequest passwordResetRequest) {

//    User user = findUserById(passwords.getUserId());
//    String currentPwdHash = user.getPassword();
//    if (!StringUtils.isEmpty(passwords.getCurrentPassword()) && !BCrypt.checkpw(passwords.getCurrentPassword(), currentPwdHash)) {
//      return "{\"error\":\"Current password is incorrect\"}";
//    }
    String newPwd = BCrypt.hashpw(passwordResetRequest.getNewPassword(), BCrypt.gensalt(10));
    User user = new User();
    user.setPassword(newPwd);
    user.setUuid(null);
    user.setId(passwordResetRequest.getUserId());
    user.setExpiryDate(null);
    saveForgotPasswordFields(user, true);
    return "{\"result\":\"Success\"}";
  }

  public static class UserMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public UserMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<FeatureAccessControl>> featureAccessRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "featureAccess",
          new JsonCollectionDeserializer(featureAccessRef, objectMapper));

      TypeReference<List<UserOrgHierarchy>> userOrgHierarchyRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "hierarchy",
          new JsonCollectionDeserializer(userOrgHierarchyRef, objectMapper));

      TypeReference<List<Company>> companiesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "companies",
          new JsonCollectionDeserializer(companiesRef, objectMapper));

      TypeReference<List<UserPosition>> userPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "userPositions",
          new JsonCollectionDeserializer(userPositionsRef, objectMapper));
    }
  }
}
