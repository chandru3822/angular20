package com.albatross.api.security;

import com.albatross.api.security.jwt.JwtClaims;
import com.albatross.api.security.jwt.JwtUtils;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.User;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/auth")
public class AuthController {

  @Autowired
  private JwtUtils jwtUtils;

  @Autowired
  private SecurityService securityService;

    @Value("${security.jwt.expireDuration}")
    private Long jwtExpireDuration;

  @GetMapping(value = "/heartbeat")
  public ResponseEntity getHeartbeat() {
    return ResponseEntity.noContent().build();
  }

  @PostMapping(value = "/login", consumes = MediaType.APPLICATION_JSON_VALUE)
  @ResponseBody
  public ResponseEntity getJwtToken(@RequestBody Credentials creds) {
    User user = securityService.getUser(creds.getUsername());
    if (user == null) {
      log.info("AUTH: Login attempted with unknown username. " + creds.getUsername());
      return ResponseEntity.badRequest().body("Invalid Username or Password");
    } else if (user.getLoginAttempts() >= 9) {
      String msg = "Too Many Attempts. Account is Locked";
      log.info("AUTH: Too many attempts; account is locked: " + creds.getUsername());
      return ResponseEntity.badRequest().body(msg);
    }

    Boolean validPassword = securityService.validatePassword(user, creds.getPassword());
    if (!validPassword) {
      int attempts = user.getLoginAttempts() + 1;
      securityService.updateLoginAttempts(attempts, user.getId());
      log.info("AUTH: Login attempted with bad password for user: " + creds.getUsername() + ": count: " + attempts);
      return ResponseEntity.badRequest().body("Invalid Username or Password");
    } else if (user.getLoginAttempts() > 0) {
      //after successful login, if any previous unsuccessful, reset the count
      securityService.updateLoginAttempts(0, user.getId());
    }

    if (!user.isUnlocked()) {
      log.info("AUTH: Cannot log in; account is locked: " + creds.getUsername());
      return ResponseEntity.badRequest().body("Account is Locked");
    }

    List<FeatureAccessControl> results = securityService.getUserFeatureAccess(user.getId(), user.getCompanyId());
    user.setFeatureAccess(results);

    JwtClaims body = createJwtBody(user);
    String jwt = jwtUtils.encodeDetails(body);
    return ResponseEntity.ok(new JwtAuthResponse(jwt, user));
  }

  private JwtClaims createJwtBody(User user) {
    Long userId = user.getId();
    Instant issuedAt = Instant.now();
    return new JwtClaims().setUserId(userId)
        .setIssuedAt(issuedAt)
        .setExpiresAt(issuedAt.plus(Duration.ofDays(jwtExpireDuration)));
  }

  @ResponseStatus(value = HttpStatus.BAD_REQUEST,
      reason = "Bad credentials")  // 400
  @ExceptionHandler({UsernameNotFoundException.class,
      BadCredentialsException.class})
  public void badCredentials() {}

  @Data
  public static class Credentials {
    private String username, password;
  }

  /**
   * This class defines what is returned from POST /auth/login
   */
  @Data
  @AllArgsConstructor
  public static class JwtAuthResponse {
    private String token;
    private User details;
  }
}
