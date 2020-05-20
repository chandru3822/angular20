package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.PostalCode;
import com.albatross.api.v1.flow.model.PostalCodeZone;
import com.albatross.api.v1.flow.model.PostalCodeZoneUser;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.PostalCodeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/postalCode")
public class PostalCodeController {

    private final PostalCodeService postalCodeService;


    @GetMapping(value = "/zones", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<PostalCodeZone> getZones() {
      return postalCodeService.getZones();
    }

    @GetMapping(value = "/zone/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public PostalCodeZone getZoneDetails(@PathVariable Long id) {
        return postalCodeService.getZone(id);
    }

    @PostMapping(value = "/zone", produces = MediaType.APPLICATION_JSON_VALUE)
    public PostalCodeZone saveZone(@RequestBody PostalCodeZone zone) {
        return postalCodeService.saveZone(zone);
    }

    @DeleteMapping(value = "/zone/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public void deleteZone(@PathVariable Long id) {
        postalCodeService.deleteZone(id);
    }

    @PostMapping(value = "/zone/saveUser", produces = MediaType.APPLICATION_JSON_VALUE)
    public PostalCodeZoneUser saveUser(@RequestBody PostalCodeZoneUser user) {
        return postalCodeService.saveUser(user);
    }

    @PostMapping(value = "/zone/saveAllocations", produces = MediaType.APPLICATION_JSON_VALUE)
    public void saveAllocations(@RequestBody List<PostalCodeZoneUser> users) {
        postalCodeService.saveAllocations(users);
    }

    @DeleteMapping(value = "/zone/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public void deleteUser(@PathVariable Long id) {
        postalCodeService.deleteUser(id);
    }

    @PostMapping(value = "/zone/addCode", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity addCode(@RequestBody PostalCode postalCode) {
        return postalCodeService.addCode(postalCode);
    }

    @DeleteMapping(value = "/zone/code/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public void deleteCode(@PathVariable Long id) {
        postalCodeService.deleteCode(id);
    }

    @GetMapping(value = "/zone/{id}/users", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getZoneUsers(@PathVariable Long id) {
        return postalCodeService.getZoneUsers(id);
    }
}
