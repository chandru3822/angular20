package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.UserController;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


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

  @Value("${security.doCompanyDefaultValidation:false}")
  private Boolean doCompanyDefaultValidation;

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
    params.put("primaryFlag", null != search.getPrimaryFlag() ? search.getPrimaryFlag() : false);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<User> results = sqlCache.query("user.searchUsers", params, new UserMapper<>(User.class, om));
    Integer count = sqlCache.queryForObject("user.searchUserCount", params, Integer.class);

    Page<User> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }

  public void saveUserHomePage(Long homePageCompanyFeatureId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("companyId", user.getCompanyId());
    params.put("homePageCompanyFeatureId", homePageCompanyFeatureId);

    sqlCache.update("user.saveUserHomePage", params);
  }

  public boolean emailExists(String email, Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("email", email);
    params.put("userId", userId);

    List<User> results = sqlCache.query("user.checkEmailExists", params, User.class);
    return null != results && !results.isEmpty();
  }

  public boolean usernameExists(String username, Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("username", username);
    params.put("userId", userId);

    List<User> results = sqlCache.query("user.checkUsernameExists", params, User.class);
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

  public Optional<User> saveUser(User user, Boolean userIsAlbatross) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", user.getFirstName());
    params.put("lastName", user.getLastName());
    params.put("phone", user.getPhoneNumber());
    params.put("email", user.getEmail());
    params.put("username", user.getUsername());
    params.put("companyId", currentUser.getCompanyId());
    params.put("homePageCompanyFeatureId", user.getHomePageCompanyFeatureId());

    Long id;

    if(null != user.getId()) {
      id = user.getId();
      params.put("modifiedById", currentUser.getId());
      params.put("id", id);
      sqlCache.update("user.updateUser", params);
      //save user status
      if(null != user.getUserStatusTypeId()) {
        saveUserStatus(true, id, user.getUserStatusTypeId());
      }
      //save user companies - we do this differently now
//      if(null != user.getCompanies()) {
//        handleSavingUserCompanies(user.getCompanies(), user.getId());
//      }
      //save user password if sent in
      if(null != user.getNewPassword()) {
        //todo: remove this check after we turn it on and mobile is working
        if(doCompanyDefaultValidation) {
          Boolean passwordIsCompanyDefault = securityService.passwordIsCompanyDefault(user.getId(), user.getNewPassword());
          if(passwordIsCompanyDefault) {
            // NOT_ACCEPTABLE = 406
            throw new ResponseStatusException(HttpStatus.NOT_ACCEPTABLE, "Cannot use company default password.", new Exception());
          } else {
            securityService.updateUserPassword(id, user.getNewPassword());
          }
        } else {
          securityService.updateUserPassword(id, user.getNewPassword());
        }
      }
    } else {
      //get the default password
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("id", currentUser.getCompanyId());
      Optional<Company> c = sqlCache.get("company.getById", p2, Company.class);
      params.put("createdById", currentUser.getId());
      String newPwd = null;
      if(c.isPresent() && null != c.get().getDefaultPassword()) {
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
      saveUserStatus(false, id, user.getUserStatusTypeId());
    }
    return getUser(id, userIsAlbatross);
  }



  public Optional<User> getUser(Long id, Boolean userIsAlbatross) {
    //this userIsAlbatross stuff was all super dumb because we can't load albatross users the same way as regular users
    User currentUser = securityService.getCurrentUser();
    // using currentUser.companyId validates that the user requesting the info can actually access this user...i think
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", currentUser.getCompanyId());
    Optional<User> result;
    if(userIsAlbatross) {
      result = sqlCache.get("user.getOneAlbatross", params, new UserMapper<>(User.class, om));
    } else {
      result = sqlCache.get("user.getOne", params, new UserMapper<>(User.class, om));
    }

    return result;
  }

  public List<User> getSchedulingUsers(Long companyStateId, Boolean isSchedulingTool) {
    //i had to change this to return user positions so that when filtering by position in the scheduling tool we have the data
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyStateId", companyStateId);
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("isSchedulingTool", isSchedulingTool);

    List<User> results = sqlCache.query("user.getSchedulingUsers", params, new UserMapper<>(User.class, om));
    return results;
  }

  public User findByUsernameIgnoreCase(String username, Long userId) {
    // i updated this to find by username or by userId so that we can call the same function on login AND on change context
    HashMap<String, Object> params = new HashMap<>();
    params.put("username", username);
    params.put("userId", userId);
    Optional<User> user = sqlCache.get("user.findByUsernameIgnoreCase", params, new UserMapper<>(User.class, om));
    return user.orElse(null);
  }

  public void updateLoginAttempts(int loginAttempts, Long userId) {
    // update count of login attempts
    HashMap<String, Object> params = new HashMap<>();
    params.put("loginAttempts", loginAttempts);
    params.put("userId", userId);
    sqlCache.update("user.updateLoginAttempts", params);
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

  public List<UserStatusType> getCompanyUserStatuses(Long companyId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", null != companyId ? companyId :user.getCompanyId());
    List<UserStatusType> results = sqlCache.query("user.getCompanyUserStatuses", params, UserStatusType.class);
    return results;
  }

  public void saveUserStatusType(UserStatusType userStatusType) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", userStatusType.getId());
    params.put("hasAccess", userStatusType.getHasAccess());
    params.put("modifiedById", user.getId());
    sqlCache.update("user.saveUserStatusType", params);
  }

  public void unlockUser(Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("loginAttempts", 0);

    sqlCache.update("user.updateLoginAttempts", params);
  }

  public List<Company> removeFromCompany(UserController.NewUserCompanyRequest req) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", req.getCompanyId());
    params.put("userId", req.getUserId());
    params.put("modifiedById", user.getId());
    sqlCache.update("user.deleteUserCompany", params);

    //per judson request also remove the user_status for that company and user
    sqlCache.update("user.archiveUserStatus", params);

    List<Company> results = sqlCache.query("user.getUserCompanies", params, Company.class);
    return results;
  }


  public List<Company> addToCompany(UserController.NewUserCompanyRequest req) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", req.getCompanyId());
    params.put("userId", req.getUserId());
    params.put("userStatusTypeId", req.getCompanyUserStatusTypeId());
    params.put("currentUserId", user.getId());
    sqlCache.update("user.upsertUserCompany", params);

    //check if there is already a user status for this user and company, if not, add new
    sqlCache.update("user.upsertUserStatus", params);
//    saveUserStatus(false, req.getUserId(), req.getCompanyUserStatusTypeId());

    List<Company> results = sqlCache.query("user.getUserCompanies", params, Company.class);
    return results;
  }

  public void saveUserStatus(Boolean update, Long userId, Long userStatusTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("currentUserId", user.getId());
    params.put("userId", userId);
    params.put("userStatusTypeId", userStatusTypeId);

    if(update) {
      sqlCache.update("user.updateUserStatus", params);
    } else {
      sqlCache.update("user.insertUserStatus", params);
    }
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
    boolean match = false;
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
      User newUserObj = findByUsernameIgnoreCase(null, user.getId());
      List<FeatureAccessControl> results = securityService.getUserFeatureAccess(newUserObj.getId(), newUserObj.getCompanyId());
      newUserObj.setFeatureAccess(results);
      return ResponseEntity.ok(newUserObj);
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
