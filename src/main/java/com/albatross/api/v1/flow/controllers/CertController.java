package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Cert;
import com.albatross.api.v1.flow.services.CertService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn 12/17/19
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/cert", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class CertController {

  private final CertService certService;

  @GetMapping(value = "")
  public List<Cert> getAllCerts() {
    return certService.getAllCerts();
  }

  @DeleteMapping(value = "/{id}")
  public void deleteCert(@PathVariable Long id) {
    certService.deleteCert(id);
  }

  @PutMapping(value = "")
  public Cert saveCert(@RequestBody Cert cert) {
    return certService.saveCert(cert);
  }

  @PostMapping(value = "/sendEmails")
  public void sendCertExpirationEmails() {
    certService.sendEmails();
  }
}
