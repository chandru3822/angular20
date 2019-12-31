package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserSearch;
import com.albatross.api.v1.flow.model.UserStatusType;
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

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/user")
public class UserController {

    private final UserService userService;

    @PostMapping(value="/search", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Page<User>> searchCustomers(@RequestBody UserSearch search, Pageable pageable) {
        return new ResponseEntity<>(userService.searchUsers(search, pageable), HttpStatus.OK);
    }

    @PostMapping(value = "/exportUsers", produces = "text/csv")
    public ResponseEntity exportUsers(@RequestBody UserSearch search) {
        return userService.exportUsers(search);
    }

    @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
    public User saveUser(@RequestBody User user) {
        return userService.saveUser(user);
    }

    @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public User getUser(@PathVariable Long id) {
        return userService.getUser(id);
    }

    @GetMapping(value = "/getSchedulingUsers", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getSchedulingUsers(@RequestParam(required = false) Long stateId) {
        return userService.getSchedulingUsers(stateId);
    }

    @GetMapping(value = "/statuses", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<UserStatusType> getUserStatuses() {
        return userService.getUserStatuses();
    }

    @GetMapping(value = "/changeContext/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity changeContext(@PathVariable Long id) {
        return userService.changeContext(id);
    }
}
