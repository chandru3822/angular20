package com.albatross.api.security.jwt;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;
import com.google.common.cache.LoadingCache;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationToken;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

import static com.google.common.base.Preconditions.checkState;

@Slf4j
@Component
public class JwtAuthenticationProvider implements AuthenticationProvider {
    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private SecurityService securityService;

    /**
     * A cache of {@link UserAccountDetails} objects, so we don't have to retrieve
     * user details of each request.
     */
    private LoadingCache<Long, Optional<UserAccountDetails>> userCache;

    @PostConstruct
    public void init() {
        checkState(securityService != null,
                "Cannot initialize without SecurityService");
        userCache = CacheBuilder.newBuilder()
                                .maximumSize(500)
                                .expireAfterWrite(30, TimeUnit.SECONDS)
                                .build(CacheLoader.from(securityService::getUserDetailsById));
    }

    @Override
    public Authentication authenticate(Authentication auth) throws AuthenticationException {
        auth.setAuthenticated(true);

        String authHeader = (String) auth.getPrincipal();
        JwtClaims token = jwtUtils.validateAuthHeader(authHeader);
        Optional<UserAccountDetails> uad = retrieveUserAccountDetails(token);
        if (!uad.isPresent()) {
            log.warn("AUTH: Attempted authentication on a JWT but could not find the specified user; token: "
                     + authHeader);
            throw new JwtUtils.JwtParseException("JWT appears corrupted.");
        }

        if (!uad.get().isAccountNonLocked()) {
            throw new LockedException("Account is locked: " + uad.get().getUsername());
        }

        UserAccountDetails uadTemp = uad.get();
        uadTemp.setMasqueradingUserId(token.getMasqueradingUserId());

        PreAuthenticatedAuthenticationToken result = new PreAuthenticatedAuthenticationToken(uadTemp, null,
                uadTemp.getAuthorities());
        return result;
    }

    @Override
    public boolean supports(Class<?> c) {
        return PreAuthenticatedAuthenticationToken.class.equals(c);
    }

    public void logFailedAuthAttempt(HttpServletRequest request, HttpServletResponse response,
                                     AuthenticationException e) throws IOException, ServletException {
        log.info("AUTH: Failed to authenticate request; exception: " + e.getMessage());
    }

    @SneakyThrows
    private Optional<UserAccountDetails> retrieveUserAccountDetails(JwtClaims token) {
        Long id = token.getUserId();

        if (id.equals(SystemSettings.BR_SYSTEM_USER.getId())) {
          User systemUser = new User();
          systemUser.setId(id);
          // @TODO hardcoded the BR system user email since we're under a tight time constraint. This needs to be more generiized with the system settings enum
          // @TODO in case we use other system users here
          systemUser.setEmail("system.admin@blueravensolar.com");
          return Optional.of(new UserAccountDetails(systemUser, Collections.emptyList()));
        } else {
          return userCache.get(id);
        }
    }

    public void forceReload(Long userId) {
      userCache.invalidate(userId);
    }
}
