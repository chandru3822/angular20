package com.albatross.api.v1.flow.controllers;


import com.albatross.api.config.ScheduledConfig;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.CommunicationService;
import com.albatross.api.v1.flow.services.UserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.io.InputStream;
import java.util.*;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/user")
public class UserController {

    private final SecurityService securityService;
    private final CommunicationService communicationService;
    private final UserService userService;

    @Value("${app.home_url}")
    private String homeUrl;

  @Value("${security.doCompanyDefaultValidation:false}")
  private Boolean doCompanyDefaultValidation;

    @PostMapping(value="/search", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Page<User>> searchUsers(@RequestBody UserSearch search, Pageable pageable) {
        return new ResponseEntity<>(userService.searchUsers(search, pageable), HttpStatus.OK);
    }

    @PutMapping(value="/homePage", produces = MediaType.APPLICATION_JSON_VALUE)
    public void saveUserHomePage(@RequestBody User user) {
        userService.saveUserHomePage(user.getHomePageCompanyFeatureId());
    }

    @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity saveUser(@RequestParam(required = false) Boolean userIsAlbatross,
                                   @RequestBody User user) {
        if (userService.emailExists(user.getEmail(), user.getId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already in use", new Exception());
        }
        if (userService.usernameExists(user.getUsername(), user.getId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already in use", new Exception());
        }
        if(null != user.getNewPassword() && user.getNewPassword().length() < 8) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid Password", new Exception());
        }
        if(user.getUsername().length() < 3) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid Username", new Exception());
        }

        Optional<User> result = userService.saveUser(user, null != userIsAlbatross ? userIsAlbatross : false);
        return result.isEmpty() ? ResponseEntity.badRequest().body("Cannot Access User") : ResponseEntity.ok(result);
    }

    @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity getUser(@PathVariable Long id,
                                  @RequestParam(required = false) Boolean userIsAlbatross) {
        Optional<User> result = userService.getUser(id, null != userIsAlbatross ? userIsAlbatross : false);
        return result.isEmpty() ? ResponseEntity.badRequest().body("Cannot Access User") : ResponseEntity.ok(result);
    }

    @GetMapping(value = "/getSchedulingUsers", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getSchedulingUsers(@RequestParam(required = false) Long companyStateId,
                                         @RequestParam Boolean isSchedulingTool) {
        return userService.getSchedulingUsers(companyStateId, isSchedulingTool);
    }

    @GetMapping(value = "/statuses", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<UserStatusType> getCompanyUserStatuses(@RequestParam(required = false) Long companyId) {
        //pass in company when the statuses you want back are not from the logged in user
        return userService.getCompanyUserStatuses(companyId);
    }

    @PutMapping(value = "/statusType", produces = MediaType.APPLICATION_JSON_VALUE)
    public void saveUserStatusType(@RequestBody UserStatusType userStatusType) {
        userService.saveUserStatusType(userStatusType);
    }

    @PutMapping(value = "/{id}/unlock", produces = MediaType.APPLICATION_JSON_VALUE)
    public void unlockUser(@PathVariable Long id) {
        userService.unlockUser(id);
    }

    @Data
    public static class NewUserCompanyRequest {
        private Long companyId, companyUserStatusTypeId, userId;
    }

    @PostMapping(value = "/removeFromCompany", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Company> removeFromCompany(@RequestBody NewUserCompanyRequest req) {
        return userService.removeFromCompany(req);
    }

    @PostMapping(value = "/addToCompany", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Company> addToCompany(@RequestBody NewUserCompanyRequest req) {
        //pass in company when the statuses you want back are not from the logged in user
        return userService.addToCompany(req);
    }

    @PostMapping(value = "/{userId}/status/{userStatusTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public void saveUserStatus(@PathVariable Long userId,
                               @PathVariable Long userStatusTypeId) {
        userService.saveUserStatus(true, userId, userStatusTypeId);
    }

    @PostMapping(value = "/changeContext/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity changeContext(@PathVariable Long id) {
        return userService.changeContext(id);
    }

    @GetMapping(value = "/current", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity getLoggedInUser() {
        return userService.getLoggedInUser();
    }

    @PostMapping(value = "/validate", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity validatePassword(@RequestBody Map<String, String> requestData) {
      Boolean response = securityService.validatePassword(requestData.get("password"));
      return response ? new ResponseEntity(HttpStatus.OK) : new ResponseEntity(HttpStatus.NOT_ACCEPTABLE);
    }

    @RequestMapping(method = RequestMethod.POST, value = "/forgotPassword", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity forgotPassword(@RequestBody PasswordResetRequest passwordResetRequest) throws Exception {
        if (!StringUtils.isEmpty(passwordResetRequest.getUsernameOrEmail())) {
            User user = securityService.getUserByUsernameOrEmail(passwordResetRequest.getUsernameOrEmail());
            if (user != null) {
                Calendar calendar = Calendar.getInstance();
                java.util.Date now = calendar.getTime();
                java.sql.Timestamp currentTimestamp = new java.sql.Timestamp(now.getTime());

                UUID uuid = UUID.randomUUID();
                user.setUuid(uuid);
                user.setExpiryDate(currentTimestamp);
                userService.saveForgotPasswordFields(user, false);

                InputStream inputStream = ScheduledConfig.class.getResourceAsStream("/communication/templates/password-reset.ftl.html");
                String template = IOUtils.toString(inputStream);

                HashMap context = new HashMap();
                context.put("link", homeUrl + "/passwordReset/" + uuid);
                context.put("from", "Blue Raven Solar Sales HR");
                context.put("mailTo", "saleshr@blueravensolar.com");

                communicationService.sendEmail("Click on link to reset your password", StringUtils.trimWhitespace(passwordResetRequest.getUsernameOrEmail()), template, context, "SalesOps@blueravensolar.com");
                log.info("AUTH: Password reset email has been sent to {}", passwordResetRequest.getUsernameOrEmail());
            } else {
                log.info("AUTH: Password reset attempted for unknown user email {}.", passwordResetRequest.getUsernameOrEmail());
                return ResponseEntity.badRequest().body("{\"message\" : \"No user found for that email or username\"}");
            }
        }
        return ResponseEntity.ok().build();
    }

    @RequestMapping(method = RequestMethod.POST, value = "/forgotPassword/change/password", produces = "application/json;charset=UTF-8")
    public String forgotPasswordChangePassword(@RequestBody PasswordResetRequest passwordResetRequest) {
        String result = null;

        if(null != passwordResetRequest.getUserId() && null != passwordResetRequest.getNewPassword()) {
          //todo: remove this check after we turn it on and mobile is working
          if(doCompanyDefaultValidation) {
            Boolean passwordIsCompanyDefault = securityService.passwordIsCompanyDefault(passwordResetRequest.getUserId(), passwordResetRequest.getNewPassword());
            if (passwordIsCompanyDefault) {
              // NOT_ACCEPTABLE = 406
              throw new ResponseStatusException(HttpStatus.NOT_ACCEPTABLE, "Cannot use company default password.", new Exception());
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

    @RequestMapping(method = RequestMethod.GET, value = "/forgotPassword/reset/{uuid}", produces = "application/json;charset=UTF-8")
    public ResponseEntity forgotPasswordReset(@PathVariable("uuid") UUID uuid) {
        final float divider = 3600000;
        User user = null;
        UUID userUuid = uuid;
        user = securityService.findUserByUuid(userUuid);

        if (user != null) {
            Calendar calendar = Calendar.getInstance();
            java.util.Date now = calendar.getTime();
            java.sql.Timestamp currentTimestamp = new java.sql.Timestamp(now.getTime());

            float time = currentTimestamp.getTime() - user.getExpiryDate().getTime();
            float time1 = time / divider;
            if (time1 > 24) {
                log.info("AUTH: Password reset for user {} attempted with expired link.", userUuid);
                ResponseEntity.badRequest().body("{\"message\" : \"This link has expired.  Please retry for a new link by clicking on the login link above.\"}");
            }

        } else {
            log.info("AUTH: Password reset attempted for unknown user {}.", userUuid);
            ResponseEntity.badRequest().body("{\"message\" : \"Can't find user for this request\"}");
        }


        return ResponseEntity.ok(user);
    }

  @GetMapping(value = "/mentionableUsers", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<User> getMentionableUsers() {
    return userService.getMentionableUsers();
  }
}
