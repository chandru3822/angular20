package com.albatross.api.v1.flow.controllers;


import com.albatross.api.exceptions.EmailInUseException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserSearch;
import com.albatross.api.v1.flow.model.CompanyUserStatusType;
import com.albatross.api.v1.flow.services.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/user")
public class UserController {

    private final SecurityService securityService;

    private final UserService userService;

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

        return userService.saveUser(user);
    }

    @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity getUser(@PathVariable Long id) {
        return userService.getUser(id);
    }

    @GetMapping(value = "/getSchedulingUsers", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getSchedulingUsers(@RequestParam(required = false) Long stateId,
                                         @RequestParam Boolean isSchedulingTool) {
        return userService.getSchedulingUsers(stateId, isSchedulingTool);
    }

    @GetMapping(value = "/statuses", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<CompanyUserStatusType> getCompanyUserStatuses() {
        return userService.getCompanyUserStatuses();
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
}
