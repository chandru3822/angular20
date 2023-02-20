package com.albatross.api.security.jwt;

import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.github.benmanes.caffeine.cache.LoadingCache;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationToken;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Collections;
import java.util.Optional;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationProvider implements AuthenticationProvider {
  private final JwtUtils jwtUtils;
  private final LoadingCache<Object, Optional<UserAccountDetails>> caffeineCache;

  @Override
  public Authentication authenticate(Authentication auth) throws AuthenticationException {
    auth.setAuthenticated(true);

    String authHeader = (String) auth.getPrincipal();
    JwtClaims token = jwtUtils.validateAuthHeader(authHeader);
    Optional<UserAccountDetails> uad = retrieveUserAccountDetails(token);
    if (uad.isEmpty()) {
      log.warn(
        "AUTH: Attempted authentication on a JWT but could not find the specified user; token: "
          + authHeader);
      throw new JwtUtils.JwtParseException("JWT appears corrupted.");
    }

    if (!uad.get().isAccountNonLocked()) {
      throw new LockedException("Account is locked: " + uad.get().getUsername());
    }

    UserAccountDetails uadTemp = uad.get();
    uadTemp.setMasqueradingUserId(token.getMasqueradingUserId());
    if (null != token.getMasqueradingUserId()) {
      uadTemp.setCompanyId(token.getCompanyId());
    }

    return new PreAuthenticatedAuthenticationToken(uadTemp, null, uadTemp.getAuthorities());
  }

  @Override
  public boolean supports(Class<?> c) {
    return PreAuthenticatedAuthenticationToken.class.equals(c);
  }

  public void logFailedAuthAttempt(
    HttpServletRequest request, HttpServletResponse response, AuthenticationException e) {
    log.error("AUTH: Failed to authenticate request; exception: {}", e.getMessage());
  }

  @SneakyThrows
  private Optional<UserAccountDetails> retrieveUserAccountDetails(JwtClaims token) {
    Long id = token.getUserId();

    SystemSettings brSystemUser = SystemSettings.BR_SYSTEM_USER;
    if (id.equals(brSystemUser.getId())) {
      User systemUser = new User();
      systemUser.setId(id);
      systemUser.setCompanyId(brSystemUser.getCompanyId());
      systemUser.setHighestCompanyId(brSystemUser.getCompanyId());
      systemUser.setParentCompanyId(brSystemUser.getCompanyId());
      systemUser.setHighestParentCompanyId(brSystemUser.getCompanyId());
      // @TODO hardcoded the BR system user email since we're under a tight time constraint. This
      // needs to be more generalized with the system settings enum
      // @TODO in case we use other system users here
      systemUser.setEmail("system.admin@blueravensolar.com");
      return Optional.of(new UserAccountDetails(systemUser, Collections.emptyList()));
    } else {
      return caffeineCache.get(id);
    }
  }

  public void forceReload(Long userId) {
    caffeineCache.invalidate(userId);
  }
}
