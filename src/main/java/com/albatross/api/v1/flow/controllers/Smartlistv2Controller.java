package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smartlistv2.Smartlistv2;
import com.albatross.api.v1.flow.services.Smartlistv2Service;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/smartlistv2")
public class Smartlistv2Controller {

  private final Smartlistv2Service smartlistv2Service;

  @GetMapping(value = "/mine", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlistv2>> getMySmartlists() {
    return new ResponseEntity<>(smartlistv2Service.getMine(), HttpStatus.OK);
  }
}
