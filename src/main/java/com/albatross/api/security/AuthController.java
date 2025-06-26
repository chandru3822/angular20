package com.albatross.api.security;

import com.albatross.api.security.jwt.JwtAuthenticationProvider;
import com.albatross.api.security.jwt.JwtClaims;
import com.albatross.api.security.jwt.JwtClaimsSerializer;
import com.albatross.api.security.jwt.JwtUtils;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.UserQuery;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.Accessors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;

import static com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL;
import static org.springframework.http.HttpStatus.FORBIDDEN;
import static org.springframework.http.HttpStatus.NOT_ACCEPTABLE;

@Slf4j
@RestController
@RequestMapping(value = "/auth")
@RequiredArgsConstructor
public class AuthController {

  private final JwtUtils jwtUtils;
  private final SecurityService securityService;
  private final JwtAuthenticationProvider jwtAuthProvider;

  @Value("${security.jwt.expireDuration}")
  private Long jwtExpireDuration;

  @Value("${security.jwt.masqueradeExpireDuration}")
  private Long jwtMasqueradeExpireDuration;

  @Value("${security.doCompanyDefaultValidation:false}")
  private Boolean doCompanyDefaultValidation;

  @Value(value = "${app.maintenanceMode:false}")
  private Boolean maintenanceMode;

  @GetMapping(value = "/heartbeat")
  public ResponseEntity<?> getHeartbeat() {
    return ResponseEntity.noContent().build();
  }

  @PostMapping(value = "/login", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> getJwtToken(@RequestBody Credentials creds,
                                       @RequestHeader(value = "User-Agent", required = false) String userAgent) {
    User user = securityService.getUser(creds.getUsername());
    if (user == null) {
      log.debug("AUTH: Login attempted with unknown username. {}", creds.getUsername());
      return ResponseEntity.badRequest().body("Invalid Username or Password");
    } else if (user.getLoginAttempts() >= 9) {
      String msg = "Too Many Attempts. Account is Locked";
      log.warn("AUTH: Too many attempts; account is locked: {}", creds.getUsername());
      return ResponseEntity.badRequest().body(msg);
    }

    if (!user.isUnlocked()) {
      log.debug("AUTH: Cannot log in; user does not have access: {}", creds.getUsername());
      return ResponseEntity.badRequest().body("This account does not have access.");
    }

// Determine device type from User-Agent with error handling
    String accessType = "web";
    String mobileVersion = null;

    try {
      // Safely get version from credentials
      String credentialsVersion = creds.getVersion();

      if (userAgent != null && !userAgent.trim().isEmpty()) {
        String ua = userAgent.toLowerCase().trim();

        if (ua.contains("android")) {
          accessType = "mobile";
          mobileVersion = (credentialsVersion != null && !credentialsVersion.trim().isEmpty()
            ? credentialsVersion + "-android" : "android");
        } else if (ua.contains("iphone")) {
          accessType = "mobile";
          mobileVersion = (credentialsVersion != null && !credentialsVersion.trim().isEmpty()
            ? credentialsVersion + "-iphone" : "iphone");
        } else if (ua.contains("ipad")) {
          accessType = "mobile";
          mobileVersion = (credentialsVersion != null && !credentialsVersion.trim().isEmpty()
            ? credentialsVersion + "-ipad" : "ipad");
        } else {
          // For web browsers, explicitly set mobileVersion to null
          accessType = "web";
          mobileVersion = null;
        }
      } else {
        // No user agent provided, default to web with null mobile version
        accessType = "web";
        mobileVersion = null;
      }

      // Log the app version if present
      if (credentialsVersion != null && !credentialsVersion.trim().isEmpty()) {
        log.info("Login attempt with app version: {}", credentialsVersion);
      } else {
        log.info("Login attempt with no version information provided");
      }

    } catch (Exception e) {
      // Fallback to safe defaults if any error occurs
      log.warn("Error processing user agent or version information, defaulting to web with null mobile version: {}", e.getMessage());
      accessType = "web";
      mobileVersion = null;
    }

    Boolean validPassword = securityService.validatePassword(user, creds.getPassword());
    if (!validPassword) {
      int attempts = user.getLoginAttempts() + 1;
      securityService.updateLoginAttempts(
        attempts, user.getId(), false, accessType, mobileVersion, user.getId(), user.getId()
      );
      log.debug(
        "AUTH: Login attempted with bad password for user={}, count={}",
        creds.getUsername(),
        attempts);
      return ResponseEntity.badRequest().body("Invalid Username or Password");
    } else {
      // after successful login, if any previous unsuccessful, reset the count
      securityService.updateLoginAttempts(
        0, user.getId(), true, accessType, mobileVersion, user.getId(), user.getId()
      );
    }

    if (doCompanyDefaultValidation) {
      if (creds.newPassword != null && !creds.newPassword.isEmpty()) {
        if(creds.newPassword.length() < 8) {
          return ResponseEntity.status(NOT_ACCEPTABLE)
            .body("New Password is too short. Please try a new password.");
        } else {
          securityService.updateUserPassword(user.getId(), creds.newPassword);
        }
      } else {
        Boolean passwordIsCompanyDefault =
          securityService.passwordIsCompanyDefault(user.getId(), creds.getPassword());
        if (passwordIsCompanyDefault) {
          log.warn(
            "AUTH: Login attempted with company default password for user={}",
            creds.getUsername());
          return ResponseEntity.status(NOT_ACCEPTABLE)
            .body("You must reset your password.");
        }
      }
    }

    List<FeatureAccessControl> results =
      securityService.getUserFeatureAccess(user.getId(), user.getCompanyId());
    user.setFeatureAccess(results);

    if (maintenanceMode
      && !securityService.userHasFeatureAccessLevel(
      user.getId(),
      user.getCompanyId(),
      user.getHighestCompanyId(),
      "MAINTENANCE_MODE",
      List.of("ADMIN"))) {
      return ResponseEntity.status(FORBIDDEN)
        .body(Map.of("message", "Site is under maintenance.", "maintenanceMode", true));
    }

    JwtClaims body = createJwtBody(user);
    String jwt = jwtUtils.encodeDetails(body);
    return ResponseEntity.ok(new JwtAuthResponse(jwt, user));
  }

  @GetMapping("/masquerade/{userId}")
  public MasqueradeResponseBody masquerade(
      @PathVariable Long userId, @RequestHeader("Authorization") String authHeader) {
    User user = securityService.getCurrentUser();

    // make sure the current user has access to masquerade
    Boolean userHasMasqueradeAccess =
        securityService.userHasFeatureAccessLevel(
            user.getId(),
            user.getCompanyId(),
            user.getHighestCompanyId(),
            "MASQUERADE",
            List.of("ADMIN"));
    // make sure that the user they are trying to masquerade as is not a 7oaks employees
    Boolean newUserIs7oaks = securityService.userIsSuperAdmin(userId);
    // make sure that the user they are trying to masquerade as has access in their current company
    Boolean newUserIsInCurrentCompany =
        securityService.userHasAccessInCompany(userId, user.getCompanyId());
    // mke sure that the user is not trying to alias as themselves
    boolean userIsSelf = user.getId().equals(userId);

    if (userHasMasqueradeAccess && !newUserIs7oaks && newUserIsInCurrentCompany && !userIsSelf) {
      Instant issuedAt = Instant.now();
      JwtClaims jwt = jwtUtils.validateAuthHeader(authHeader);
      jwt.setMasqueradingUserId(user.getId());
      jwt.setCompanyId(user.getCompanyId());
      // masquerading sessions will time out after 30 mins
      jwt.setExpiresAt(issuedAt.plus(Duration.ofMinutes(jwtMasqueradeExpireDuration)));
      jwt.setUserId(userId);
      jwtAuthProvider.forceReload(userId);
      return new MasqueradeResponseBody().setResult("success").setToken(jwt);
    } else {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "You do not have access to masquerade as this user.",
          new Exception());
    }
  }

  @GetMapping("/masquerade/clear")
  public MasqueradeResponseBody clearMasquerade(@RequestHeader("Authorization") String authHeader) {
    JwtClaims jwt = jwtUtils.validateAuthHeader(authHeader);
    Instant issuedAt = Instant.now();
    // invalidate the logged in user jwt
    // set the user id on the new jwt to the masquerading user id
    jwt.setUserId(jwt.getMasqueradingUserId());
    // clear the masq user id
    jwt.setMasqueradingUserId(null);
    jwt.setCompanyId(null);
    // reset the expiration to 7 days
    jwt.setExpiresAt(issuedAt.plus(Duration.ofDays(jwtExpireDuration)));
    jwtAuthProvider.forceReload(securityService.getCurrentUser().getId());
    return new MasqueradeResponseBody().setResult("success").setToken(jwt);
  }

  private JwtClaims createJwtBody(User user) {
    Long userId = user.getId();
    Instant issuedAt = Instant.now();
    return new JwtClaims()
        .setUserId(userId)
        .setIssuedAt(issuedAt)
        .setExpiresAt(issuedAt.plus(Duration.ofDays(jwtExpireDuration)));
  }

  @ResponseStatus(value = HttpStatus.BAD_REQUEST, reason = "Bad credentials") // 400
  @ExceptionHandler({UsernameNotFoundException.class, BadCredentialsException.class})
  public void badCredentials() {}

  @JsonInclude(NON_NULL)
  @Data
  @Accessors(chain = true)
  public static class MasqueradeResponseBody {
    private String result;

    @JsonSerialize(using = JwtClaimsSerializer.class)
    private JwtClaims token;
  }

  @Data
  public static class Credentials {
    private String username, password, newPassword, version;
  }

  /** This class defines what is returned from POST /auth/login */
  @Data
  @AllArgsConstructor
  public static class JwtAuthResponse {
    private String token;
    private User details;
  }
}
