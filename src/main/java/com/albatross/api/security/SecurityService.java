package com.albatross.api.security;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.model.UserPermission;
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

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class SecurityService implements UserDetailsService {

    @Autowired
    private UserService userService;

    @Autowired
    private SqlCache sqlCache;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Look up a user by email (which is our "username" in this case)
     */
    @Override
    public UserAccountDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = getUser(email);
        if (user == null) {
            throw new UsernameNotFoundException("Could not find user " + email);
        }
        List<UserPermission> permissions = this.getUserPermissions(user.getId());
        return new UserAccountDetails(user, permissions);
    }

    public User getUser(String email) {
        User user = userService.findByEmailIgnoreCase(email);
        return user;
    }

    public Optional<UserAccountDetails> getUserDetailsById(Long id) {
        Optional<User> user = findUserById(id);
        if (!user.isPresent()) {
            return Optional.empty();
        }
        List<UserPermission> permissions = getUserPermissions(user.get().getId());
        return Optional.of(new UserAccountDetails(user.get(), permissions));
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
                user = userService.findByEmailIgnoreCase(details.getUsername());

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
//        List<Permission> permissions = permissionsService.getUserPermissions(userId, false);
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
    public List<UserPermission> getUserPermissions(Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        List<UserPermission> userPermissions = sqlCache.query("permission.getUserPermissions", params, UserPermission.class);
        return userPermissions;
    }

//    public boolean hasPermission(UserAccountDetails uad, String permissionName) {
//        if(uad == null ){
//            return false;
//        }
//
//        List<String> auths = uad.getAuthorities()
//                                .stream()
//                                .map(GrantedAuthority::getAuthority)
//                                .collect(Collectors.toList());
//
//        if( auths.contains("HR_ADMIN") ){
//            return true;
//        }
//
//        return auths.contains(permissionName);
//    }
//
//    public void ensurePermission(UserAccountDetails uad, String permissionName){
//        if( !hasPermission(uad, permissionName) ){
//            throw new InsufficientAuthenticationException("Missing permission: " + permissionName);
//        }
//    }

//    @SuppressWarnings("unchecked")
//    public List<UserRoleDO> getUserRoles(Long userId) {
//        String sql = "select r.id,r.role_name,ur.id as userRoleId " +
//                "from blueraven.user_role ur " +
//                "inner join blueraven.role r on r.id = ur.role_id " +
//                "where ur.user_id = :userId " +
//                "   and r.archived is not true ";
//        List<Object[]> results = entityManager.createNativeQuery(sql).setParameter("userId", userId)
//                .getResultList();
//
//        List<UserRoleDO> userRoleDOs = new ArrayList<>();
//        for (Object[] row : results) {
//            UserRoleDO userRoleDO = new UserRoleDO();
//            userRoleDO.setRoleId((Integer) row[0]);
//            userRoleDO.setRoleName((String) row[1]);
//            userRoleDO.setId((Integer) row[2]);
//            userRoleDOs.add(userRoleDO);
//        }
//        return userRoleDOs;
//    }

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

