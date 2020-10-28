package com.albatross.api.security;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import java.util.*;

@Service
public class SecurityService implements UserDetailsService {

    @Autowired
    private UserService userService;

    @Autowired
    private SqlCache sqlCache;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Look up a user by username
     */
    @Override
    public UserAccountDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = getUser(username);
        if (user == null) {
            throw new UsernameNotFoundException("Could not find user " + username);
        }
        // todo: come back and add permissions when the re-write is complete
        List<FeatureAccessControl> results = this.getUserFeatureAccess(user.getId(), user.getCompanyId());
        return new UserAccountDetails(user, results);
    }

    public User getUser(String username) {
        User user = userService.findByUsernameIgnoreCase(username, null);
        return user;
    }

    public User getUserByUsernameOrEmail(String usernameOrEmail) {
        User user = userService.findByUsernameOrEmailIgnoreCase(usernameOrEmail);
        return user;
    }

    public Optional<UserAccountDetails> getUserDetailsById(Long id) {
        Optional<User> user = findUserById(id);
        if (!user.isPresent()) {
            return Optional.empty();
        }
        List<FeatureAccessControl> results = getUserFeatureAccess(user.get().getId(), user.get().getCompanyId());
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
            } else if (p instanceof UserAccountDetails) {
                UserAccountDetails details = (UserAccountDetails) p;
                user = userService.findUserById(details.getId());
                List<FeatureAccessControl> results = getUserFeatureAccess(details.getId(), user.getCompanyId());
                user.setFeatureAccess(results);

            } else {
//                    throw new IllegalStateException("Unhandled Security Principal type: " + p);
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

//    /**
//     * Returns an {@link EndUser} object for the user represented by
//     * <code>masqueradeUserId</code>, but with the
//     * {@link com.blueraven.dto.EndUser.Min#actuallyLoggedInUserId}
//     * set ot the real user id.
//     *
//     * @param masqueradeUserId the masquarade id
//     * @param realUserId       the actual user's id
//     * @param realUserName     the actual user's username
//     * @return a {@link EndUser} object for the specified user
//     */
//    public EndUser getMasquaradingEndUser(Long masqueradeUserId, Long realUserId, String realUserName) {
//        EndUser o = getEndUser(masqueradeUserId, realUserName);
//        o.getMin().setMasqueradeId(masqueradeUserId);
//        o.getMin().setActuallyLoggedInUserId(realUserId);
//        o.getMin().setLoggedInUserPermissions(permissionsService.getUserPermissions(realUserId, false));
//        return o;
//    }

//    /**
//     * Returns an {@link EndUser} object for the user represented by <code>userId</code>.
//     *
//     * @param userId the id of the user to fetch
//     * @param name   the username of the user to fetch
//     * @return a {@link EndUser} object for the specified user
//     */
//    public EndUser getEndUser(Long userId, String name) {
//        HashMap<String, Object> params = new HashMap<>();
//        params.put("userId", userId);
//
//        //user.min
//        EndUser.Min min = new EndUser.Min();
//        min.setId(userId);
//        min.setMasqueradeId(null);
//        min.setName(name);
//        min.setActuallyLoggedInUserId(userId);
//
//        //user.details
//        User details = userRepository.findOne(userId);
//        details.setPresignedImageUrl(userService.getUserPresignedImageUrl());
//
//        //user.positions
//        List<UserPosition> positions = positionService.getUserPositions(userId);
//
//        //user.roles
//        List<UserRoleDO> roles = getUserRoles(userId);
//
//        //user.preferences
//        //cant inject PreferenceService or it creates a cycle and kills the build in prod
//        Optional<Preferences> preferences = sqlCache.get("preferences.getUserPrefs", params, Preferences.class);
//
//        //user.permissions
//        List<FeatureAccessControl> results = permissionsService.getUserFeatureAccess(userId, false);
//
//        EndUser endUser = new EndUser();
//
//        endUser.setMin(min);
//        endUser.setDetails(details);
//        endUser.setPositions(positions);
//        endUser.setRoles(roles);
//        endUser.setPreferences(preferences.orElse(null));
//        endUser.setPermissions(permissions);
//
//        return endUser;
//    }

    public UserAccountDetails getRequiredCurrentUserDetails() {
        UserAccountDetails result = getCurrentUserDetails();
        Assert.notNull(result, "Couldn't determine current user");
        return result;
    }


    public static Authentication getRequiredAuthentication() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Assert.notNull(auth, "Authentication not found");
        return auth;
    }

    @SuppressWarnings("unchecked")
    public List<FeatureAccessControl> getUserFeatureAccess(Long userId, Long companyId) {
        //this function gets ALL access for a user (combining user/position access control as needed)
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("companyId", companyId);
        List<FeatureAccessControl> results = sqlCache.query("feature.getAccessForUser", params, FeatureAccessControl.class);
        return results;
    }

    /*
    Return whether user has any of the given access levels to the given feature
     */
    public Boolean userHasFeatureAccessLevel(Long userId, Long companyId, Long userHighestCompanyId, String featureCode, List<String> accessCode) {
        List<FeatureAccessControl> featureAccessControlList = getUserFeatureAccess(userId, companyId);
        for(FeatureAccessControl fac : featureAccessControlList) {
            if(fac.getFeatureCode().equals(featureCode) && accessCode.contains(fac.getAccessCode())) {
                return true;
            }
        }
        //if the user's highest company id is 1, then they are an albatross system admin - 7 oaks employee
        //we return true for all features, access levels, etc for ^^ these users
        return userHighestCompanyId == 1;
    }

    @SuppressWarnings("unchecked")
    public Boolean validatePassword(String password){
        User currentUser = getCurrentUser();
        return validatePassword(currentUser, password);
    }

    public Boolean validatePassword(User user, String password){
        Boolean match = passwordEncoder.matches(password, user.getPassword());
        return match;
    }

    public void setCurrentUserDetails(UserAccountDetails uad) {
        SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(uad, null, uad.getAuthorities()));
    }
}

