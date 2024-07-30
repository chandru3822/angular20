package com.albatross.api.security;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.queries.CompanyQuery;
import com.albatross.api.v1.flow.queries.FeatureQuery;
import com.albatross.api.v1.flow.queries.UserPositionQuery;
import com.albatross.api.v1.flow.queries.UserQuery;
import com.albatross.api.v1.flow.services.UserPositionService;
import com.albatross.api.v1.flow.services.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class SecurityService implements UserDetailsService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final PasswordEncoder passwordEncoder;

  /**
   * Look up a user by username
   */
  @Override
  public UserAccountDetails loadUserByUsername(String username) throws UsernameNotFoundException {
    User user = findByUsernameIgnoreCase(username);
    if (user == null) {
      throw new UsernameNotFoundException("Could not find user " + username);
    }
    List<FeatureAccessControl> results = getUserFeatureAccess(user.getId(), user.getCompanyId());
    return new UserAccountDetails(user, results);
  }

  public User getUser(String username) {
    return findByUsernameIgnoreCase(username);
  }

  private User findByUsernameIgnoreCase(String username) {
    // i updated this to find by username or by userId so that we can call the same function on
    // login AND on change context
    HashMap<String, Object> params = new HashMap<>();
    params.put("username", username);
    params.put("userId", null);
    // had to make a change cuz for a 7oaks employee in a non-alba context it wasn't loading some
    // company specific columns we needed on the frontend
    return sqlCache.getBySql(UserQuery.findByUsernameIgnoreCase, params, new UserService.UserMapper<>(User.class, om))
      .orElse(null);
  }


  public void updateLoginAttempts(int loginAttempts, Long userId) {
    // update count of login attempts
    HashMap<String, Object> params = new HashMap<>();
    params.put("loginAttempts", loginAttempts);
    params.put("userId", userId);
    sqlCache.updateBySql(UserQuery.updateLoginAttempts, params);
  }

  public Optional<UserAccountDetails> getUserDetailsById(Long id) {
    User userById = findUserById(id);
    return Optional.ofNullable(userById)
      .map(user -> {
        List<FeatureAccessControl> results =
          getUserFeatureAccess(user.getId(), user.getCompanyId());
        return new UserAccountDetails(user, results);
      });
  }

  public User getCurrentUser() {
    User user = null;

    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth != null) {
      Object p = auth.getPrincipal();
      if (p == null) {
        // don't do anything
      } else if (p instanceof User user1) {
        user = user1;
      } else if (p instanceof UserAccountDetails details) {

        if (details.getId().equals(SystemSettings.CRON_USER.getId())) {
          // @TODO: Once we start onboarding a second company, we will need a cron user per company
          user = new User();
          user.setId(details.getId());
          user.setCompanyId(3L);
          user.setHighestCompanyId(3L);
          user.setParentCompanyId(3L);
          user.setUserPositions(new ArrayList<>());
          user.setHighestParentCompanyId(3L);
          user.setHasAccess(true);
        } else if (details.getId().equals(SystemSettings.BR_SYSTEM_USER.getId())) {
          // @TODO: humes, this is temporary until we have bandwidth to develop a legit 3rd party
          // API access feature
          user = new User();
          user.setCompanyId(3L);
          user.setHighestCompanyId(3L);
          user.setAwsBucket("blueraven");
          user.setParentCompanyId(3L);
          user.setHighestParentCompanyId(3L);
          user.setUserPositions(new ArrayList<>());
          user.setId(details.getId());
          user.setHasAccess(true);
        } else {
          user = findUserById(details.getId());
          user.setMasqueradingUserId(((UserAccountDetails) p).getMasqueradingUserId());
          // if the user is masquerading - hard code their company id to the current one so we dont
          // override the user's default
          if (null != ((UserAccountDetails) p).getMasqueradingUserId()
              && null != ((UserAccountDetails) p).getCompanyId()) {
            user.setCompanyId(((UserAccountDetails) p).getCompanyId());
          }
          List<FeatureAccessControl> results =
            getUserFeatureAccess(details.getId(), user.getCompanyId());
          user.setFeatureAccess(results);
          UserPosition userPosition = getUserPrimaryPosition(user.getId(), user.getCompanyId());
          if (userPosition != null) {
            user.setUserPositionId(userPosition.getPositionId());
            user.setPrimaryPosition(userPosition.getPosition());
          }
        }

      } else {
        //                    throw new IllegalStateException("Unhandled Security Principal type: "
        // + p);
      }
    }
    return user;
  }

  private UserPosition getUserPrimaryPosition(Long userId, Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", companyId);

    return sqlCache
      .getBySql(
        UserPositionQuery.getUserPrimaryPosition,
        params,
        new UserPositionService.UserPositionMapper<>(UserPosition.class, om))
      .orElse(null);
  }

  private User findUserById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    // note: i had to change this query a bunch cuz if it was a 7oaks employee it was not returning
    // the company's api path or aws bucket even when in that context
    return sqlCache.getBySql(UserQuery.findUserById, params, new UserService.UserMapper<>(User.class, om)).orElse(null);
  }

  public UserAccountDetails getCurrentUserDetails() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth != null) {
      Object p = auth.getPrincipal();
      if (p instanceof UserAccountDetails details) {
        return details;
      }
    }
    return null;
  }

  public void setCurrentUserDetails(UserAccountDetails uad) {
    SecurityContextHolder.getContext()
      .setAuthentication(
        new UsernamePasswordAuthenticationToken(uad, null, uad.getAuthorities()));
  }

  public List<FeatureAccessControl> getUserFeatureAccess(Long userId, Long companyId) {
    // this function gets ALL access for a user (combining user/position access control as needed)
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", companyId);
    return sqlCache.queryBySql(FeatureQuery.getAccessForUser, params, FeatureAccessControl.class);
  }

  public List<FeatureAccessControl> getMasqueradedUserFeatureAccess(
    Long userId, Long companyId, Long trueUserId) {
    // this function gets ALL access for a user (combining user/position access control as needed)
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", companyId);
    params.put("trueUserId", trueUserId);
    return sqlCache.queryBySql(
      FeatureQuery.getMasqueradedUserFeatureAccess, params, FeatureAccessControl.class);
  }

  public void updateUserPassword(Long userId, String newPassword) {
    HashMap<String, Object> params = new HashMap<>();
    String newPwd = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));
    params.put("password", newPwd);
    params.put("id", userId);
    sqlCache.updateBySql(UserQuery.saveUserPassword, params);
  }

  public Boolean userIsSuperAdmin(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    return sqlCache
      .queryForObjectOptionalBySql(UserQuery.isSuperAdmin, params, Boolean.class)
      .orElse(false);
  }

  // use to validate masquerading user stuff
  public Boolean userHasAccessInCompany(Long userId, Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", companyId);

    return sqlCache
      .queryForObjectOptionalBySql(UserQuery.hasAccessInCompany, params, Boolean.class)
      .orElse(false);
  }

  /*
  Return whether user has any of the given access levels to the given feature
   */
  public Boolean userHasFeatureAccessLevel(
    Long userId,
    Long companyId,
    Long userHighestCompanyId,
    String featureCode,
    List<String> accessCodes) {
    List<FeatureAccessControl> featureAccessControlList = getUserFeatureAccess(userId, companyId);
    for (FeatureAccessControl fac : featureAccessControlList) {
      if (fac.getFeatureCode().equals(featureCode) && accessCodes.contains(fac.getAccessCode())) {
        return true;
      }
    }
    // if the user's highest company id is 1, then they are an albatross system admin - 7 oaks
    // employee
    // we return true for all features, access levels, etc for ^^ these users
    return userHighestCompanyId == 1;
  }

  /*
  Return whether user has any of the positions requested
   */
  public Boolean userHasPosition(
    Long userHighestCompanyId,
    List<Long> positionIdsToCheckFor,
    List<UserPosition> userPositions) {
    for (UserPosition up : userPositions) {
      if (positionIdsToCheckFor.contains(up.getPositionId())) {
        return true;
      }
    }
    // if the user's highest company id is 1, then they are an albatross system admin - 7 oaks
    // employee
    // we return true for all features, access levels, etc for ^^ these users
    return userHighestCompanyId == 1;
  }

  public void validateUserFeatureAccessLevel(
    Long userId,
    Long companyId,
    Long userHighestCompanyId,
    String featureCode,
    List<String> accessCodes) {
    if (!userHasFeatureAccessLevel(
      userId, companyId, userHighestCompanyId, featureCode, accessCodes)) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized.", new Exception());
    }
  }

  public Boolean validatePassword(String password) {
    User currentUser = getCurrentUser();
    return validatePassword(currentUser, password);
  }

  public Boolean validatePassword(User user, String password) {
    if (null == user.getPassword() || user.getPassword().isEmpty()) {
      log.warn("AUTH: Attempted login user has no password. {}", user.getEmail());
      return false;
    }
    return passwordEncoder.matches(password, user.getPassword());
  }

  public Boolean passwordIsCompanyDefault(Long userId, String password) {
    // have to check if the user's password matches ANY company default that they have access to
    boolean match = false;
    List<Company> companiesUserHasAccessTo = getCompaniesAssignedToUser(userId);

    for (Company c : companiesUserHasAccessTo) {
      if (password.equalsIgnoreCase(c.getDefaultPassword())) {
        match = true;
        break;
      }
    }
    return match;
  }

  private List<Company> getCompaniesAssignedToUser(Long userId) {
    return sqlCache.queryBySql(CompanyQuery.getCompaniesAssignedToUser, Map.of("userId", userId), Company.class);
  }
}
