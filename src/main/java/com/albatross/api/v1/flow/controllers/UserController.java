package com.albatross.api.v1.flow.controllers;

import com.albatross.api.config.ScheduledConfig;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.services.CommunicationService;
import com.albatross.api.v1.flow.services.SmsTeamService;
import com.albatross.api.v1.flow.services.UserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.io.InputStream;
import java.util.*;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/user", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class UserController {

  private final SecurityService securityService;
  private final CommunicationService communicationService;
  private final SmsTeamService smsTeamService;
  private final UserService userService;

  @Value("${app.home_url}")
  private String homeUrl;

  @Value("${security.doCompanyDefaultValidation:false}")
  private Boolean doCompanyDefaultValidation;

  @PostMapping(value = "/search")
  public ResponseEntity<Page<User>> searchUsers(@RequestBody UserSearch search, Pageable pageable) {
    return new ResponseEntity<>(userService.searchUsers(search, pageable), HttpStatus.OK);
  }

  @PutMapping(value = "/homePage")
  public void saveUserHomePage(@RequestBody User user) {
    userService.saveUserHomePage(user.getHomePageCompanyFeatureId());
  }

  @PutMapping(value = "")
  public ResponseEntity saveUser(
      @RequestParam(required = false) Boolean userIsAlbatross, @RequestBody User user) {
    if (userService.emailExists(user.getEmail(), user.getId())) {
      throw new ResponseStatusException(
          HttpStatus.CONFLICT, "Email already in use", new Exception());
    }
    if (userService.usernameExists(user.getUsername(), user.getId())) {
      throw new ResponseStatusException(
          HttpStatus.CONFLICT, "Username already in use", new Exception());
    }
    if (null != user.getNewPassword()
        && !user.getNewPassword().isEmpty()
        && user.getNewPassword().length() < 8) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Invalid Password", new Exception());
    }
    if (user.getUsername() != null && user.getUsername().length() < 3) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Invalid Username", new Exception());
    }

    Optional<User> result =
        userService.saveUser(user, null != userIsAlbatross ? userIsAlbatross : false);
    return result.isEmpty()
        ? ResponseEntity.badRequest().body("Cannot Access User")
        : ResponseEntity.ok(result);
  }

  @GetMapping(value = "/{id}")
  public ResponseEntity getUser(
      @PathVariable Long id, @RequestParam(required = false) Boolean userIsAlbatross) {
    Optional<User> result =
        userService.getUser(id, null != userIsAlbatross ? userIsAlbatross : false);
    if(result.isEmpty()) {
      throw new NotFoundException("FAIL_TO_NOT_FOUND_SCREEN");
    } else {
      return ResponseEntity.ok(result);
    }
  }

  @GetMapping(value = "/active")
  public List<User> getAllActiveUsers() {
    return userService.getAllActiveUsers();
  }

  @GetMapping(value = "/getSchedulingUsers")
  public List<User> getSchedulingUsers(
      @RequestParam(required = false) Long companyStateId, @RequestParam Boolean isSchedulingTool) {
    return userService.getSchedulingUsers(companyStateId, isSchedulingTool);
  }

  @GetMapping(value = "/statuses")
  public List<UserStatusType> getCompanyUserStatuses(
      @RequestParam(required = false) Long companyId) {
    // pass in company when the statuses you want back are not from the logged in user
    return userService.getCompanyUserStatuses(companyId);
  }

  @PutMapping(value = "/statusType")
  public void saveUserStatusType(@RequestBody UserStatusType userStatusType) {
    userService.saveUserStatusType(userStatusType);
  }

  @PutMapping(value = "/{id}/unlock")
  public void unlockUser(@PathVariable Long id) {
    userService.unlockUser(id);
  }

  @PostMapping(value = "/removeFromCompany")
  public List<Company> removeFromCompany(@RequestBody NewUserCompanyRequest req) {
    return userService.removeFromCompany(req);
  }

  @PostMapping(value = "/addToCompany")
  public List<Company> addToCompany(@RequestBody NewUserCompanyRequest req) {
    // pass in company when the statuses you want back are not from the logged in user
    return userService.addToCompany(req);
  }

  @PostMapping(value = "/{userId}/status/{userStatusTypeId}")
  public void saveUserStatus(@PathVariable Long userId, @PathVariable Long userStatusTypeId) {
    userService.saveUserStatus(true, userId, userStatusTypeId);
  }

  @PostMapping(value = "/changeContext/{id}")
  public ResponseEntity changeContext(@PathVariable Long id) {
    return userService.changeContext(id);
  }

  @GetMapping(value = "/current")
  public ResponseEntity getLoggedInUser(@RequestHeader("Authorization") String authHeader) {
    return userService.getLoggedInUser(authHeader);
  }

  @PostMapping(value = "/validate")
  public ResponseEntity validatePassword(@RequestBody Map<String, String> requestData) {
    Boolean response = securityService.validatePassword(requestData.get("password"));
    return response
        ? new ResponseEntity(HttpStatus.OK)
        : new ResponseEntity(HttpStatus.NOT_ACCEPTABLE);
  }

  @PostMapping(value = "/forgotPassword")
  public ResponseEntity forgotPassword(@RequestBody PasswordResetRequest passwordResetRequest)
      throws Exception {
    if (!StringUtils.isEmpty(passwordResetRequest.getUsernameOrEmail())) {
      User user =
          securityService.getUserByUsernameOrEmail(passwordResetRequest.getUsernameOrEmail());
      if (user != null) {
        Calendar calendar = Calendar.getInstance();
        java.util.Date now = calendar.getTime();
        java.sql.Timestamp currentTimestamp = new java.sql.Timestamp(now.getTime());

        UUID uuid = UUID.randomUUID();
        user.setUuid(uuid);
        user.setExpiryDate(currentTimestamp);
        userService.saveForgotPasswordFields(user, false);

        InputStream inputStream =
            ScheduledConfig.class.getResourceAsStream(
                "/communication/templates/password-reset.ftl.html");
        String template = IOUtils.toString(inputStream);

        Map<String, Object> context = new HashMap<>();
        context.put("link", homeUrl + "/passwordReset/" + uuid);
        context.put("from", "Blue Raven Solar Sales HR");
        context.put("mailTo", "saleshr@blueravensolar.com");

        communicationService.sendEmail(
            "Click on link to reset your password",
            StringUtils.trimWhitespace(passwordResetRequest.getUsernameOrEmail()),
            template,
            context,
            "SalesOps@blueravensolar.com",
            "Blue Raven Sales Operation",
            user.trueUserId());
        log.debug(
            "AUTH: Password reset email has been sent to {}",
            passwordResetRequest.getUsernameOrEmail());
      } else {
        log.debug(
            "AUTH: Password reset attempted for unknown user email {}.",
            passwordResetRequest.getUsernameOrEmail());
        return ResponseEntity.badRequest()
            .body(Map.of("message", "No user found for that email or username"));
      }
    }
    return ResponseEntity.ok().build();
  }

  @PostMapping(value = "/forgotPassword/change/password")
  public String forgotPasswordChangePassword(
      @RequestBody PasswordResetRequest passwordResetRequest) {
    String result = null;

    if (null != passwordResetRequest.getUserId() && null != passwordResetRequest.getNewPassword()) {
      // todo: remove this check after we turn it on and mobile is working
      if (doCompanyDefaultValidation) {
        Boolean passwordIsCompanyDefault =
            securityService.passwordIsCompanyDefault(
                passwordResetRequest.getUserId(), passwordResetRequest.getNewPassword());
        if (passwordIsCompanyDefault) {
          // NOT_ACCEPTABLE = 406
          throw new ResponseStatusException(
              HttpStatus.NOT_ACCEPTABLE, "Cannot use company default password.", new Exception());
        } else {
          result = userService.updatePassword(passwordResetRequest);
          userService.updateLoginAttempts(0, passwordResetRequest.getUserId());
        }
      } else {
        result = userService.updatePassword(passwordResetRequest);
        userService.updateLoginAttempts(0, passwordResetRequest.getUserId());
      }
    }

    return result;
  }

  @GetMapping(value = "/forgotPassword/reset/{uuid}")
  public ResponseEntity forgotPasswordReset(@PathVariable("uuid") UUID userUuid) {
    final float divider = 3600000;
    User user = securityService.findUserByUuid(userUuid);

    if (user != null) {
      Calendar calendar = Calendar.getInstance();
      java.util.Date now = calendar.getTime();
      java.sql.Timestamp currentTimestamp = new java.sql.Timestamp(now.getTime());

      float time = currentTimestamp.getTime() - user.getExpiryDate().getTime();
      float time1 = time / divider;
      if (time1 > 24) {
        log.warn("AUTH: Password reset for user {} attempted with expired link.", userUuid);
        ResponseEntity.badRequest()
            .body(
                Map.of(
                    "message",
                    "This link has expired.  Please retry for a new link by clicking on the login link above."));
      }

    } else {
      log.debug("AUTH: Password reset attempted for unknown user {}.", userUuid);
      ResponseEntity.badRequest().body(Map.of("message", "Can't find user for this request"));
    }

    return ResponseEntity.ok(user);
  }

  @GetMapping(value = "/mentionableUsers")
  public List<User> getMentionableUsers() {
    return userService.getMentionableUsers();
  }

  @PostMapping(value = "/{userId}/token")
  public ResponseEntity<Void> addTokenToUser(
      @PathVariable Long userId, @RequestBody UserNotificationTokenDTO token) {
    userService.addNotificationToken(userId, token.getToken());
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @GetMapping(value = "/{userId}/attachments")
  public ResponseEntity<List<Attachment>> getUserAttachments(
      @PathVariable Long userId, @PathVariable(required = false) Boolean isMobile) {
    return new ResponseEntity<>(userService.getUserAttachments(userId, isMobile), HttpStatus.OK);
  }

  @PostMapping(value = "/{userId}/attachment")
  public ResponseEntity<Attachment> uploadUserAttachment(
      @PathVariable Long userId,
      @RequestParam Long attachmentTypeId,
      @RequestParam("file") MultipartFile file)
      throws IOException {
    return new ResponseEntity<>(
        userService.addAttachment(file, userId, attachmentTypeId), HttpStatus.OK);
  }

  @GetMapping(value = "/getTeamsForUser/{userId}")
  public List<SmsTeam> getTeamsForUser(@PathVariable Long userId) {
    return smsTeamService.getTeamsForUser(userId);
  }

  @PutMapping(value = "/{userId}/saveSmsTeamNotifications")
  public void saveSmsTeamNotification(@PathVariable Long userId, @RequestBody List<SmsTeam> smsTeams) {
    userService.saveSmsTeamNotification(userId, smsTeams);
  }

  @Data
  public static class NewUserCompanyRequest {
    private Long companyId, companyUserStatusTypeId, userId;
  }
}
