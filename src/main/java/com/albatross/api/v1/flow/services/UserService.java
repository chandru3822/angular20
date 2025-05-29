package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.RevokeAccessMessage;
import com.albatross.api.security.SecurityService;
import com.albatross.api.security.jwt.JwtAuthenticationProvider;
import com.albatross.api.security.jwt.JwtClaims;
import com.albatross.api.security.jwt.JwtUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.controllers.UserController;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.queries.CompanyQuery;
import com.albatross.api.v1.flow.queries.MessagingQuery;
import com.albatross.api.v1.flow.queries.SmsTeamQuery;
import com.albatross.api.v1.flow.queries.UserQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

  private final AttachmentService attachmentService;
  private final SqlCache sqlCache;
  private final SqlCacheRO sqlCacheRO;
  private final SecurityService securityService;
  private final MessagingService messagingService;
  private final SmsTeamService smsTeamService;
  private final UserPositionService userPositionService;
  private final ObjectMapper om;
  private final JwtUtils jwtUtils;
  private final PubSubService pubSubService;
  private final JwtAuthenticationProvider jwtAuthProvider;

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
    params.put("initials","");

    List<User> results = sqlCacheRO.queryBySql(UserQuery.searchUsers, params, new UserMapper<>(User.class, om));

    return new PageImpl<>(
      results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), 100000);
  }

  public void saveUserHomePage(Long homePageCompanyFeatureId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("companyId", user.getCompanyId());
    params.put("homePageCompanyFeatureId", homePageCompanyFeatureId);

    sqlCache.updateBySql(UserQuery.saveUserHomePage, params);
  }

  public void updateTestUserPasswords(String password) {
    User user = securityService.getCurrentUser();

    String newPwd = BCrypt.hashpw(password, BCrypt.gensalt(10));

    HashMap<String, Object> params = new HashMap<>();
    params.put("password", newPwd);
    params.put("userId", user.trueUserId());
    params.put("companyId", user.getCompanyId());

    sqlCache.updateBySql(UserQuery.updateTestUserPasswords, params);
  }

  public boolean emailExists(String email, Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("email", email);
    params.put("userId", userId);

    List<User> results = sqlCache.queryBySql(UserQuery.checkEmailExists, params, User.class);
    return null != results && !results.isEmpty();
  }

  public boolean usernameExists(String username, Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("username", username);
    params.put("userId", userId);

    List<User> results = sqlCache.queryBySql(UserQuery.checkUsernameExists, params, User.class);
    return null != results && !results.isEmpty();
  }

  public void saveForgotPasswordFields(User user, Boolean updatePassword) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", user.getId());
    params.put("uuid", user.getUuid());
    params.put("expiryDate", user.getExpiryDate());

    sqlCache.updateBySql(UserQuery.saveForgotPasswordFields, params);
    if (updatePassword) {
      params.put("password", user.getPassword());
      sqlCache.updateBySql(UserQuery.saveUserPassword, params);
    }
  }

  public Optional<User> saveUser(User user, Boolean userIsAlbatross) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", user.getFirstName());
    params.put("lastName", user.getLastName());
    params.put("phone", user.getPhoneNumber());
    params.put("phoneExtension", user.getPhoneExtension());
    params.put("email", user.getEmail());
    params.put("notificationTypeId", user.getNotificationTypeId());
    params.put("username", user.getUsername());
    params.put("companyId", currentUser.getCompanyId());
    params.put("homePageCompanyFeatureId", user.getHomePageCompanyFeatureId());
    params.put("defaultProjectPage", user.getDefaultProjectPage());

    Long id;

    if (null != user.getId()) {
      id = user.getId();
      params.put("modifiedById", currentUser.trueUserId());
      params.put("id", id);
      sqlCache.updateBySql(UserQuery.updateUser, params);
      // save user status
      if (null != user.getUserStatusTypeId()) {
        saveUserStatus(true, id, user.getUserStatusTypeId());
      }
      // save user password if sent in
      if (null != user.getNewPassword() && !user.getNewPassword().isEmpty()) {
        // todo: remove this check after we turn it on and mobile is working
        if (doCompanyDefaultValidation) {
          Boolean passwordIsCompanyDefault =
            securityService.passwordIsCompanyDefault(user.getId(), user.getNewPassword());
          if (passwordIsCompanyDefault) {
            // NOT_ACCEPTABLE = 406
            throw new ResponseStatusException(
              HttpStatus.NOT_ACCEPTABLE, "Please use a different password.", new Exception());
          } else {
            securityService.updateUserPassword(id, user.getNewPassword());
          }
        } else {
          securityService.updateUserPassword(id, user.getNewPassword());
        }
      }
    } else {
      // get the default password
      Optional<Company> c = sqlCache.getBySql(CompanyQuery.getById, Map.of("id", currentUser.getCompanyId()), Company.class);
      params.put("createdById", currentUser.trueUserId());
      String newPwd = null;
      if (c.isPresent() && null != c.get().getDefaultPassword()) {
        newPwd = BCrypt.hashpw(c.get().getDefaultPassword(), BCrypt.gensalt(10));
      }
      params.put("defaultPassword", newPwd);
      // for now we are inserting new users with the same email and username. maybe we will change
      // that later and let them enter it here
      id = sqlCache.updateBySqlReturningId(UserQuery.insertUser, params, "id").longValue();
      // insert a row into user_company
      params.put("id", id);
      params.put("isDefault", true);
      sqlCache.updateBySql(UserQuery.insertUserCompany, params);
      // insert a row into user_status
      saveUserStatus(false, id, user.getUserStatusTypeId());
    }
    return getUser(id, userIsAlbatross);
  }

  public Optional<User> getUser(Long id, Boolean userIsAlbatross) {
    // this userIsAlbatross stuff was all super dumb because we can't load albatross users the same
    // way as regular users
    User currentUser = securityService.getCurrentUser();
    // todo: check the logs for this and figure out how it is possible this is happening
    try {
      // using currentUser.companyId validates that the user requesting the info can actually access
      // this user...i think
      Map<String, Object> params = new HashMap<>();
      params.put("id", id);
      params.put("companyId", currentUser.getCompanyId());
      Optional<User> result;
      if (userIsAlbatross) {
        result = sqlCache.getBySql(UserQuery.getOneAlbatross, params, new UserMapper<>(User.class, om));
      } else {
        result = sqlCache.getBySql(UserQuery.getOne, params, new UserMapper<>(User.class, om));
      }
      return result;
    } catch (Exception e) {
      log.error(
        "USER: Main user query returned more than 1 result. {} user={}",
        e.getMessage(),
        currentUser.getId());
      return Optional.empty();
    }
  }

  public List<User> findByIds(List<Long> ids) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("ids", ids);
    params.put("companyId", currentUser.getCompanyId());

    return sqlCache.queryBySql(UserQuery.getByIds, params, new UserMapper<>(User.class, om));
  }

  public List<User> getAllActiveUsers() {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());

    return sqlCache.queryBySql(UserQuery.getAllActiveUsers, params, new UserMapper<>(User.class, om));
  }

  public List<User> getSchedulingUsers(Long companyStateId, Boolean isSchedulingTool) {
    // i had to change this to return user positions so that when filtering by position in the
    // scheduling tool we have the data
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    Map<String, Object> params = new HashMap<>();
    params.put("companyStateId", companyStateId);
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("isSchedulingTool", isSchedulingTool);

    return sqlCache.queryBySql(UserQuery.getSchedulingUsers, params, new UserMapper<>(User.class, om));
  }

  public User findByUsernameIgnoreCase(String username, Long userId) {
    // i updated this to find by username or by userId so that we can call the same function on
    // login AND on change context
    Map<String, Object> params = new HashMap<>();
    params.put("username", username);
    params.put("userId", userId);
    // had to make a change cuz for a 7oaks employee in a non-alba context it wasn't loading some
    // company specific columns we needed on the frontend
    Optional<User> user =
      sqlCache.getBySql(UserQuery.findByUsernameIgnoreCase, params, new UserMapper<>(User.class, om));
    return user.orElse(null);
  }


  public User findByUsernameOrEmailIgnoreCase(String usernameOrEmail) {
    // for forgot password they need to be able to enter username or email. this will find them
    // either way
    Map<String, Object> params = new HashMap<>();
    params.put("usernameOrEmail", usernameOrEmail);
    return sqlCache
      .getBySql(UserQuery.findByUsernameOrEmailIgnoreCase, params, new UserMapper<>(User.class, om))
      .orElse(null);
  }

  public User findUserById(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    // note: i had to change this query a bunch cuz if it was a 7oaks employee it was not returning
    // the company's api path or aws bucket even when in that context
    return sqlCache.getBySql(UserQuery.findUserById, params, new UserMapper<>(User.class, om)).orElse(null);
  }

  public List<UserStatusType> getCompanyUserStatuses(Long companyId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", null != companyId ? companyId : user.getCompanyId());
    return sqlCache.queryBySql(UserQuery.getCompanyUserStatuses, params, UserStatusType.class);
  }

  public void saveUserStatusType(UserStatusType userStatusType) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("id", userStatusType.getId());
    params.put("hasAccess", userStatusType.getHasAccess());
    params.put("modifiedById", user.trueUserId());
    sqlCache.updateBySql(UserQuery.saveUserStatusType, params);
  }

  public void unlockUser(Long userId) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("loginAttempts", 0);

    sqlCache.updateBySql(UserQuery.updateLoginAttempts, params);
  }

  public List<Company> removeFromCompany(UserController.NewUserCompanyRequest req) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", req.getCompanyId());
    params.put("userId", req.getUserId());
    params.put("modifiedById", user.trueUserId());
    sqlCache.updateBySql(UserQuery.deleteUserCompany, params);

    // per judson request also remove the user_status for that company and user
    sqlCache.updateBySql(UserQuery.archiveUserStatus, params);

    return sqlCache.queryBySql(UserQuery.getUserCompanies, params, Company.class);
  }

  public List<Company> addToCompany(UserController.NewUserCompanyRequest req) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", req.getCompanyId());
    params.put("userId", req.getUserId());
    params.put("userStatusTypeId", req.getCompanyUserStatusTypeId());
    params.put("currentUserId", user.trueUserId());
    sqlCache.updateBySql(UserQuery.upsertUserCompany, params);

    // check if there is already a user status for this user and company, if not, add new
    sqlCache.updateBySql(UserQuery.upsertUserStatus, params);

    return sqlCache.queryBySql(UserQuery.getUserCompanies, params, Company.class);
  }

  public void saveUserStatus(Boolean update, Long userId, Long userStatusTypeId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("currentUserId", user.trueUserId());
    params.put("userId", userId);
    params.put("userStatusTypeId", userStatusTypeId);

    if (update) {
      sqlCache.updateBySql(UserQuery.updateUserStatus, params);
    } else {
      sqlCache.updateBySql(UserQuery.insertUserStatus, params);
    }

    List<UserStatusType> userStatusTypes = getCompanyUserStatuses(user.getCompanyId());
    Optional<UserStatusType> newUserStatusType = userStatusTypes.stream().filter(ust -> ust.getId().equals(userStatusTypeId)).findFirst();
    if (newUserStatusType.isPresent()) {
      // If no longer Active, remove User from SMS Teams and SMS Owners
      // a user can still have access to the system even if their status is not active. Changed this to check their "hasAccess" status
      if (!newUserStatusType.get().getHasAccess()) {
        //send pub sub notification to kick them out
        revokeUserAccess(userId);

        UserPosition primaryPosition = userPositionService.getUserPrimaryPosition(userId, user.getCompanyId());
        if (primaryPosition != null) {
          // If the user has a primary position, remove the user from any SMS teams associated to their position or org
          smsTeamService.deleteUserByUserId(userId, primaryPosition.getOrgId(), primaryPosition.getPositionId());
        } else {
          // Remove user from any SMS teams they've been added to via User
          smsTeamService.deleteUserByUserId(userId, null, null);
        }
        // Remove all teams and owners from this User's conversation
        Long threadId = messagingService.removeAllTeamsFromThread(null, null, userId, user.trueUserId());
        messagingService.removeAllUsersFromThread(null, null, userId, user.trueUserId());
        try {
          if(null != threadId) {
            //by not sending a user id this will remove all unread notifications for this thread
            messagingService.markSmsThreadNotificationsAsRead(threadId, null, null, user.trueUserId());
          }
        } catch (SQLException e) {
          throw new RuntimeException(e);
        }
      }
      //this tells the jwt to reload the user details (ensuring that an inactive user cannot hit the api)
      jwtAuthProvider.forceReload(userId);

    }
  }

  public User changeContext(Long companyId) {
    User user = securityService.getCurrentUser();
    return user.getHighestCompanyId() == 1L
      ? changeContextAdmin(companyId)
      : changeContextNonAdmin(companyId);
  }

  private User changeContextAdmin(Long companyId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("companyId", companyId);

    sqlCache.updateBySql(UserQuery.updateAdminDefault, params);

    return findByUsernameIgnoreCase(null, user.getId());
  }

  private User changeContextNonAdmin(Long companyId) {
    User user = securityService.getCurrentUser();
    boolean match = false;
    // get list of companies the user has access to
    Map<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    List<Company> companies =
      sqlCache.queryBySql(CompanyQuery.getCompaniesAssignedToUser, params, Company.class);

    // verify they have access to the company id that was sent in
    for (Company c : companies) {
      if (c.getId().equals(companyId)) {
        match = true;
        break;
      }
    }

    // if valid, update the default for the user and return full user details including permissions
    if (match) {
      params.put("companyId", companyId);
      sqlCache.updateBySql(UserQuery.updateDefault, params);
      User newUserObj = findByUsernameIgnoreCase(null, user.getId());
      List<FeatureAccessControl> results =
        securityService.getUserFeatureAccess(newUserObj.getId(), newUserObj.getCompanyId());
      newUserObj.setFeatureAccess(results);
      return newUserObj;
    }

    return null;
  }

  public User getLoggedInUser(String authHeader) {
    User user = securityService.getCurrentUser();
    JwtClaims jwt = jwtUtils.validateAuthHeader(authHeader);
    if (null != user) {
      User response = findUserById(user.getId());
      List<FeatureAccessControl> results;
      if (null != user.getMasqueradingUserId() && null != jwt.getCompanyId()) {
        response.setCompanyId(jwt.getCompanyId());

        // check if the masquerading user is a 7oaks employee
        Boolean masqueradingUserIs7oaks =
          securityService.userIsSuperAdmin(user.getMasqueradingUserId());
        if (!masqueradingUserIs7oaks) {
          // if the masquerading user is not 7oaks/super admin - then need to remove any  access that
          // the masquerading user does not ALSO have access to
          results =
            securityService.getMasqueradedUserFeatureAccess(
              user.getId(), jwt.getCompanyId(), user.getMasqueradingUserId());
        } else {
          // if the masquerading user is a 7oaks employee/super admin - then just use their normal
          // access
          results = securityService.getUserFeatureAccess(user.getId(), user.getCompanyId());
        }
      } else {
        // regular access getter
        results = securityService.getUserFeatureAccess(user.getId(), user.getCompanyId());
      }

      response.setFeatureAccess(results);
      response.setMasqueradingUserId(user.getMasqueradingUserId());
      return response;
    }

    return null;
  }

  public String updatePassword(PasswordResetRequest passwordResetRequest) {

    String newPwd = BCrypt.hashpw(passwordResetRequest.getNewPassword(), BCrypt.gensalt(10));
    User user = new User();
    user.setPassword(newPwd);
    user.setUuid(null);
    user.setId(passwordResetRequest.getUserId());
    user.setExpiryDate(null);
    saveForgotPasswordFields(user, true);
    return "{\"result\":\"Success\"}";
  }

  @Data
  public static class MentionableUser {
    private Long id;
    private String firstName, lastName, fullName, value, email;
  }

  public List<MentionableUser> getMentionableUsers() {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("parentCompanyId", currentUser.getHighestParentCompanyId());

    return sqlCache.queryBySql(UserQuery.mentionableUsers, params, MentionableUser.class);
  }

  public void addNotificationToken(Long userId, String token, Boolean mobile) {
    try {
      sqlCache.updateBySql(
        UserQuery.addNotificationToken,
        Map.of("userId", userId, "token", token, "createdById", userId, "mobile", null != mobile ? mobile : false));
    } catch (Exception e) {
      log.warn("Unable to add token={} for userId={}", token, userId);
    }
  }

  public void removeNotificationToken(Long userId, String token) {
    try {
      sqlCache.updateBySql(
        UserQuery.removeNotificationToken,
        Map.of("userId", userId, "token", token));
    } catch (Exception e) {
      log.warn("Unable to remove token={} from userId={}", token, userId);
    }
  }

  public List<Attachment> getUserAttachments(Long userId, Boolean isMobile, Boolean linked) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("linked", linked);
    params.put("companyId", currentUser.getCompanyId());
    List<Attachment> attachments =
      sqlCache.queryBySql(UserQuery.getUserAttachments, params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, null != isMobile ? isMobile : false);
  }

  public void linkAttachment(Long userId, Long attachmentId, Boolean doLink) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("attachmentId", attachmentId);
    params.put("currentUserId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    String sql = UserQuery.linkAttachment;
    if (!doLink) {
      sql = UserQuery.unlinkAttachment;
    }
    sqlCache.updateBySql(sql, params);
  }

  public Attachment addAttachment(MultipartFile file, Long userId, Long attachmentTypeId, String displayName)
    throws IOException {

    User user = securityService.getCurrentUser();
    Attachment attachment = attachmentService.create(file, null, attachmentTypeId, displayName, false);

    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("attachmentId", attachment.getId());
    params.put("createdById", user.trueUserId());

    sqlCache.updateBySql(UserQuery.addAttachment, params);

    return attachment;
  }

  public void saveSmsTeamNotification(Long userId, List<SmsTeam> smsTeams) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    for (SmsTeam smsTeam : smsTeams) {
      params.put("smsTeamId", smsTeam.getId());
      if (smsTeam.getReceiveUnassignedNotifications() != null && smsTeam.getReceiveUnassignedNotifications()) {
        sqlCache.updateBySql(SmsTeamQuery.upsertSmsTeamUserUnassignedNotification, params);
      } else {
        params.put("modifiedById", userId);
        sqlCache.updateBySql(SmsTeamQuery.deleteSmsTeamUserUnassignedNotification, params);
      }
    }
  }

  public void revokeUserAccess(Long userId) {
    jwtAuthProvider.forceReload(userId);
    RevokeAccessMessage ram = new RevokeAccessMessage();
    ram.setUserId(userId);
    pubSubService.publish(EventChannel.NOTIFICATION, ram);
  }

  public boolean hasSmsAccess(Long userId) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    return sqlCache
      .queryForObjectOptionalBySql(UserQuery.getSmsAccess, params, Boolean.class)
      .orElse(false);
  }

  public User findUserByUuid(UUID uuid) {
    Map<String, Object> params = new HashMap<>();
    params.put("uuid", uuid);
    return sqlCache.getBySql(UserQuery.findByUserUuid, params, User.class).orElse(null);
  }

  public List<BasicNotificationUser> getNotificationEnabledUsers(String query, Pageable pageable) {
    Map<String, Object> params = new HashMap<>();
    params.put("query", query);
    params.put("offset", pageable.getOffset());
    params.put("limit", pageable.getPageSize());
    return sqlCache.queryBySql(UserQuery.getNotificationEnabledUsers, params, new BeanPropertyRowMapper<>(BasicNotificationUser.class));
  }

  public static class UserMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public UserMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<FeatureAccessControl>> featureAccessRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "featureAccess",
        new JsonCollectionDeserializer<>(featureAccessRef, objectMapper));

      TypeReference<List<UserOrgHierarchy>> userOrgHierarchyRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "hierarchy",
        new JsonCollectionDeserializer<>(userOrgHierarchyRef, objectMapper));

      TypeReference<List<Company>> companiesRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "companies", new JsonCollectionDeserializer<>(companiesRef, objectMapper));

      TypeReference<List<UserPosition>> userPositionsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "userPositions",
        new JsonCollectionDeserializer<>(userPositionsRef, objectMapper));

      TypeReference<List<Long>> notificationTokensRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "notificationTokens",
        new JsonCollectionDeserializer<>(notificationTokensRef, objectMapper));

      TypeReference<List<Long>> partnerIdsRef = new TypeReference<>(){};
      bw.registerCustomEditor(
        List.class,
        "partnerIds",
        new JsonCollectionDeserializer<>(partnerIdsRef, objectMapper)
      );
    }
  }
}
