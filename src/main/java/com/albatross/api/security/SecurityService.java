package com.albatross.api.security;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.CompanyService;
import com.albatross.api.v1.flow.services.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
public class SecurityService implements UserDetailsService {

  @Autowired private UserService userService;

  @Autowired private CompanyService companyService;

  @Autowired private SqlCache sqlCache;

  @Autowired private PasswordEncoder passwordEncoder;

  public static Authentication getRequiredAuthentication() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    Assert.notNull(auth, "Authentication not found");
    return auth;
  }

  /** Look up a user by username */
  @Override
  public UserAccountDetails loadUserByUsername(String username) throws UsernameNotFoundException {
    User user = getUser(username);
    if (user == null) {
      throw new UsernameNotFoundException("Could not find user " + username);
    }
    // todo: come back and add permissions when the re-write is complete
    List<FeatureAccessControl> results = getUserFeatureAccess(user.getId(), user.getCompanyId());
    return new UserAccountDetails(user, results);
  }

  public User getUser(String username) {
    return userService.findByUsernameIgnoreCase(username, null);
  }

  public User getUserByUsernameOrEmail(String usernameOrEmail) {
    return userService.findByUsernameOrEmailIgnoreCase(usernameOrEmail);
  }

  public void updateLoginAttempts(int loginAttempts, Long userId) {
    userService.updateLoginAttempts(loginAttempts, userId);
  }

  public Optional<UserAccountDetails> getUserDetailsById(Long id) {
    Optional<User> user = findUserById(id);
    if (user.isEmpty()) {
      return Optional.empty();
    }
    List<FeatureAccessControl> results =
        getUserFeatureAccess(user.get().getId(), user.get().getCompanyId());
    return Optional.of(new UserAccountDetails(user.get(), results));
  }

  public boolean isLoggedIn() {
    return getCurrentUser() != null;
  }

  public User getCurrentUser() {
    User user = null;

    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth != null) {
      Object p = auth.getPrincipal();
      if (p == null) {
        // don't do anything
      } else if (p instanceof User) {
        user = (User) p;
      } else if (p instanceof UserAccountDetails details) {

        if (details.getId().equals(SystemSettings.CRON_USER.getId())) {
          // @TODO: Once we start onboarding a second company, we will need a cron user per company
          user = new User();
          user.setId(details.getId());
          user.setCompanyId(3L);
          user.setHighestCompanyId(3L);
          user.setParentCompanyId(3L);
          user.setHighestParentCompanyId(3L);
        } else if (details.getId().equals(SystemSettings.BR_SYSTEM_USER.getId())) {
          // @TODO: humes, this is temporary until we have bandwidth to develop a legit 3rd party
          // API access feature
          user = new User();
          user.setCompanyId(3L);
          user.setHighestCompanyId(3L);
          user.setParentCompanyId(3L);
          user.setHighestParentCompanyId(3L);
          user.setId(details.getId());
        } else {
          user = userService.findUserById(details.getId());
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
        }

      } else {
        //                    throw new IllegalStateException("Unhandled Security Principal type: "
        // + p);
      }
    }
    return user;
  }

  public User findUserByUuid(UUID uuid) {
    return userService.findByUserUuid(uuid);
  }

  public Optional<User> findUserById(Long id) {
    return Optional.ofNullable(userService.findUserById(id));
  }

  public UserAccountDetails getCurrentUserDetails() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth != null) {
      Object p = auth.getPrincipal();
      if (p instanceof UserAccountDetails) {
        return (UserAccountDetails) p;
      }
    }
    return null;
  }

  public void setCurrentUserDetails(UserAccountDetails uad) {
    SecurityContextHolder.getContext()
        .setAuthentication(
            new UsernamePasswordAuthenticationToken(uad, null, uad.getAuthorities()));
  }

  public UserAccountDetails getRequiredCurrentUserDetails() {
    UserAccountDetails result = getCurrentUserDetails();
    Assert.notNull(result, "Couldn't determine current user");
    return result;
  }

  public List<FeatureAccessControl> getUserFeatureAccess(Long userId, Long companyId) {
    // this function gets ALL access for a user (combining user/position access control as needed)
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", companyId);
    return sqlCache.query("feature.getAccessForUser", params, FeatureAccessControl.class);
  }

  public List<FeatureAccessControl> getMasqueradedUserFeatureAccess(
      Long userId, Long companyId, Long trueUserId) {
    // this function gets ALL access for a user (combining user/position access control as needed)
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", companyId);
    params.put("trueUserId", trueUserId);
    return sqlCache.query(
        "feature.getMasqueradedUserFeatureAccess", params, FeatureAccessControl.class);
  }

  public void updateUserPassword(Long userId, String newPassword) {
    HashMap<String, Object> params = new HashMap<>();
    String newPwd = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));
    params.put("password", newPwd);
    params.put("id", userId);
    sqlCache.update("user.saveUserPassword", params);
  }

  public Boolean userIsSuperAdmin(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    return sqlCache
        .queryForObjectOptional("user.isSuperAdmin", params, Boolean.class)
        .orElse(false);
  }

  // use to validate masquerading user stuff
  public Boolean userHasAccessInCompany(Long userId, Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", companyId);

    return sqlCache
        .queryForObjectOptional("user.hasAccessInCompany", params, Boolean.class)
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
    List<Company> companiesUserHasAccessTo = companyService.getCompaniesAssignedToUser(userId);

    for (Company c : companiesUserHasAccessTo) {
      if (password.equalsIgnoreCase(c.getDefaultPassword())) {
        match = true;
        break;
      }
    }
    return match;
  }

  public void validateCompanyAccess(Long companyId) {
    User user = getCurrentUser();
    if (!user.getCompanyId().equals(companyId)) {
      throw new ResponseStatusException(
          HttpStatus.UNAUTHORIZED, "You do not have access to this company data.", new Exception());
    }
  }
}
