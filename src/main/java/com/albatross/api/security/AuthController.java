package com.albatross.api.security;

import com.albatross.api.security.jwt.JwtAuthenticationProvider;
import com.albatross.api.security.jwt.JwtClaims;
import com.albatross.api.security.jwt.JwtClaimsSerializer;
import com.albatross.api.security.jwt.JwtUtils;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.Accessors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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

import static com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL;
import static org.springframework.http.HttpStatus.NOT_ACCEPTABLE;

@Slf4j
@RestController
@RequestMapping(value = "/auth")
public class AuthController {

  @Autowired
  private JwtUtils jwtUtils;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private JwtAuthenticationProvider jwtAuthProvider;

  @Value("${security.jwt.expireDuration}")
  private Long jwtExpireDuration;

  @Value("${security.jwt.masqueradeExpireDuration}")
  private Long jwtMasqueradeExpireDuration;

  @Value("${security.doCompanyDefaultValidation:false}")
  private Boolean doCompanyDefaultValidation;

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
      log.info("AUTH: Cannot log in; user does not have access: " + creds.getUsername());
      return ResponseEntity.badRequest().body("This account does not have access.");
    }

    //cannot turn this on in prod until mobile is ready
    //todo: remove this check after we turn it on and mobile is working
    if(doCompanyDefaultValidation) {
      if(null != creds.newPassword) {
        // called after user was already told they needed to reset their password
        securityService.updateUserPassword(user.getId(), creds.newPassword);
      } else {
        //validate that the user's password is not the same as the company default for any company they have access to
        Boolean passwordIsCompanyDefault = securityService.passwordIsCompanyDefault(user.getId(), creds.getPassword());
        if(passwordIsCompanyDefault) {
          log.info("AUTH: Login attempted with company default password for user: " + creds.getUsername());
          // NOT_ACCEPTABLE = 406
          return ResponseEntity.status(NOT_ACCEPTABLE).body("You must reset your password. Cannot use company default.");
        }
      }
    }

    List<FeatureAccessControl> results = securityService.getUserFeatureAccess(user.getId(), user.getCompanyId());
    user.setFeatureAccess(results);

    JwtClaims body = createJwtBody(user);
    String jwt = jwtUtils.encodeDetails(body);
    return ResponseEntity.ok(new JwtAuthResponse(jwt, user));
  }

  @RequestMapping("/masquerade/{userId}")
  @ResponseBody
  public MasqueradeResponseBody masquerade(@PathVariable("userId") Long userId,
                                           @RequestHeader("Authorization") String authHeader) {
    User user = securityService.getCurrentUser();

    //make sure the current user has access to masquerade
    Boolean userHasMasqueradeAccess = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "MASQUERADE", List.of("ADMIN"));
    //make sure that the user they are trying to masquerade as is not a 7oaks employees
    Boolean newUserIs7oaks = securityService.userIsSuperAdmin(userId);
    //make sure that the user they are trying to masquerade as has access in their current company
    Boolean newUserIsInCurrentCompany = securityService.userHasAccessInCompany(userId, user.getCompanyId());

    if(userHasMasqueradeAccess && !newUserIs7oaks && newUserIsInCurrentCompany) {
      Instant issuedAt = Instant.now();
      JwtClaims jwt = jwtUtils.validateAuthHeader(authHeader);
      jwt.setMasqueradingUserId(user.getId());
      jwt.setCompanyId(user.getCompanyId());
      //masquerading sessions will time out after 30 mins
      jwt.setExpiresAt(issuedAt.plus(Duration.ofMinutes(jwtMasqueradeExpireDuration)));
      jwt.setUserId(userId);
      jwtAuthProvider.forceReload(userId);
      return new MasqueradeResponseBody().setResult("success")
        .setToken(jwt);
    } else {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You do not have access to masquerade as this user.", new Exception());
    }
  }

  @RequestMapping("/masquerade/clear")
  @ResponseBody
  public MasqueradeResponseBody clearMasquerade(@RequestHeader("Authorization") String authHeader) {
    JwtClaims jwt = jwtUtils.validateAuthHeader(authHeader);
    Instant issuedAt = Instant.now();
    //invalidate the logged in user jwt
    //set the user id on the new jwt to the masquerading user id
    jwt.setUserId(jwt.getMasqueradingUserId());
    //clear the masq user id
    jwt.setMasqueradingUserId(null);
    jwt.setCompanyId(null);
    //reset the expiration to 7 days
    jwt.setExpiresAt(issuedAt.plus(Duration.ofDays(jwtExpireDuration)));
    jwtAuthProvider.forceReload(securityService.getCurrentUser().getId());
    return new MasqueradeResponseBody().setResult("success")
      .setToken(jwt);
  }

  @JsonInclude(NON_NULL)
  @Data
  @Accessors(chain = true)
  private static class MasqueradeResponseBody {
    private String result;

    @JsonSerialize(using = JwtClaimsSerializer.class)
    private JwtClaims token;
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
    private String username, password, newPassword;
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
