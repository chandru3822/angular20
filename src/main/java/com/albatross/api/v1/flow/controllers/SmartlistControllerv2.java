package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smartlistv2.Smartlistv2;
import com.albatross.api.v1.flow.services.SmartlistServicev2;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@PreAuthorize("hasFeatureAccess('SMARTLIST')")
@RequestMapping(value = "/api/v1/flow/smartlistv2")
public class SmartlistControllerv2 {

  private final SmartlistServicev2 smartlistServicev2;

  @GetMapping(value = "/mine", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlistv2>> getMySmartlists() {
    return new ResponseEntity<>(smartlistServicev2.getMine(), HttpStatus.OK);
  }

  @GetMapping(value = "/public", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlistv2>> getPublicSmartlists() {
    return new ResponseEntity<>(smartlistServicev2.getPublic(), HttpStatus.OK);
  }
}
