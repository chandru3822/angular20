package com.albatross.api.v1.flow.controllers;


import com.albatross.api.config.ScheduledConfig;
import com.albatross.api.exceptions.EmailInUseException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.UserStatusType;
import com.albatross.api.v1.flow.model.PasswordResetRequest;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserSearch;
import com.albatross.api.v1.flow.services.CommunicationService;
import com.albatross.api.v1.flow.services.UserService;
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

    @Value("${reset_url}")
    private String resetUrl;

    @PostMapping(value="/search", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Page<User>> searchUsers(@RequestBody UserSearch search, Pageable pageable) {
        return new ResponseEntity<>(userService.searchUsers(search, pageable), HttpStatus.OK);
    }

    @PostMapping(value = "/exportUsers", produces = "text/csv")
    public ResponseEntity exportUsers(@RequestBody UserSearch search) {
        return userService.exportUsers(search);
    }

    @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity saveUser(@RequestBody User user) throws EmailInUseException {
        if (userService.emailExists(user.getEmail(), user.getId())) {
            throw new EmailInUseException(user.getEmail(), "Email");
        }

        Optional<User> result = userService.saveUser(user);
        return result.isEmpty() ? ResponseEntity.badRequest().body("Cannot Access User") : ResponseEntity.ok(result);
    }

    @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity getUser(@PathVariable Long id) {
        Optional<User> result = userService.getUser(id);
        return result.isEmpty() ? ResponseEntity.badRequest().body("Cannot Access User") : ResponseEntity.ok(result);
    }

    @GetMapping(value = "/getSchedulingUsers", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getSchedulingUsers(@RequestParam(required = false) Long stateId,
                                         @RequestParam Boolean isSchedulingTool) {
        return userService.getSchedulingUsers(stateId, isSchedulingTool);
    }

    @GetMapping(value = "/statuses", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<UserStatusType> getCompanyUserStatuses() {
        return userService.getCompanyUserStatuses();
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
                context.put("link", resetUrl + "/passwordReset/" + uuid);
                context.put("from", "Blue Raven Solar Sales HR");
                context.put("mailTo", "saleshr@blueravensolar.com");

                communicationService.sendEmail("Click on link to reset your password", StringUtils.trimWhitespace(passwordResetRequest.getUsernameOrEmail()), template, context, "SalesOps@blueravensolar.com");
                log.info("Password reset email has been sent to {}", passwordResetRequest.getUsernameOrEmail());
            } else {
                log.info("Password reset attempted for unknown user email {}.", passwordResetRequest.getUsernameOrEmail());
                return ResponseEntity.badRequest().body("{\"message\" : \"No user found for that email or username\"}");
            }
        }
        return ResponseEntity.ok().build();
    }

    @RequestMapping(method = RequestMethod.POST, value = "/forgotPassword/change/password", produces = "application/json;charset=UTF-8")
    public String forgotPasswordChangePassword(@RequestBody PasswordResetRequest passwordResetRequest) {
        String result = null;
        try {
            if(null != passwordResetRequest.getUserId() && null != passwordResetRequest.getNewPassword()) {
                result = userService.updatePassword(passwordResetRequest);
            }

        } catch (Exception e) {
            throw new RuntimeException("Error updating password!");
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
                log.info("Password reset for user {} attempted with expired link.", userUuid);
                ResponseEntity.badRequest().body("{\"message\" : \"This link has expired.  Please retry for a new link by clicking on the login link above.\"}");
            }

        } else {
            log.info("Password reset attempted for unknown user {}.", userUuid);
            ResponseEntity.badRequest().body("{\"message\" : \"Can't find user for this request\"}");
        }


        return ResponseEntity.ok(user);
    }
}
