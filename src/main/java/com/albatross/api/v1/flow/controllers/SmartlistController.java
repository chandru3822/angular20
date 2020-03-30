package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Smartlist;
import com.albatross.api.v1.flow.services.SmartlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/smartlist")
public class SmartlistController {

  private final SmartlistService smartlistService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<Smartlist>> getSmartlists() {
    return new ResponseEntity<>(smartlistService.getSmartlists(), HttpStatus.OK);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> addSmartlist(@RequestBody Smartlist smartlist) {
    return new ResponseEntity<>(smartlistService.addSmartlist(smartlist), HttpStatus.OK);
  }

  @GetMapping(value = "/{smartlistId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Smartlist> getSmartlist(@PathVariable Long smartlistId) {
    return new ResponseEntity<>(smartlistService.getSmartlist(smartlistId), HttpStatus.OK);
  }

  @PutMapping(value = "/{smartlistId}", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateSmartlist(@RequestBody Smartlist smartlist) {
    smartlistService.updateSmartlist(smartlist);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }
}
