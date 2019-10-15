package com.albatross.api.security;

import com.albatross.api.security.jwt.JwtClaims;
import com.albatross.api.security.jwt.JwtUtils;
import com.albatross.api.v1.flow.model.User;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

@Slf4j
@RestController
@RequestMapping(value = "/auth")
public class AuthController {

  @Autowired
  private JwtUtils jwtUtils;

  @Autowired
  private SecurityService securityService;

  @PostMapping(value = "/login", consumes = MediaType.APPLICATION_JSON_VALUE)
  @ResponseBody
  public ResponseEntity getJwtToken(@RequestBody Credentials creds) {
    User user = securityService.getUser(creds.getUsername());
    if (user == null) {
      log.info("Login attempted with unknown username"
          + (log.isDebugEnabled() ? ": " + creds.getUsername()
          : "."));
      return ResponseEntity.badRequest().body("No such username found");
    }

    Boolean validPassword = securityService.validatePassword(user, creds.getPassword());
    if (!validPassword) {
      log.info("Login attempted with bad password for user: " + creds.getUsername());
      return ResponseEntity.badRequest().body("Invalid password");
    }

    if (!user.isUnlocked()) {
      String msg = "Cannot log in; account is locked: " + creds.getUsername();
      log.info(msg);
      return ResponseEntity.badRequest().body(msg);
    }

    JwtClaims body = createJwtBody(user);
    String jwt = jwtUtils.encodeDetails(body);
    return ResponseEntity.ok(new JwtAuthResponse(jwt, user));
  }

  private JwtClaims createJwtBody(User user) {
    Long userId = user.getId();
    Instant issuedAt = Instant.now();
    return new JwtClaims().setUserId(userId)
        .setIssuedAt(issuedAt);
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
