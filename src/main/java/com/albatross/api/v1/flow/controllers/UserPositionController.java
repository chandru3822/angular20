package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.UserPosition;
import com.albatross.api.v1.flow.services.UserPositionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/userPosition")
public class UserPositionController {

    private final UserPositionService userPositionService;

    @GetMapping(value="/{userId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<UserPosition> getUserPositions(@PathVariable Long userId) {
        return userPositionService.getUserPositions(userId);
    }

}
