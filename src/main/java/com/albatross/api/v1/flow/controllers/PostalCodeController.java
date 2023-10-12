package com.albatross.api.v1.flow.controllers;


import com.albatross.api.v1.flow.model.PostalCode;
import com.albatross.api.v1.flow.model.PostalCodeZone;
import com.albatross.api.v1.flow.services.PostalCodeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/postalCode")
public class PostalCodeController {

  private final PostalCodeService postalCodeService;


  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCode> getPostalCodes() {
    return postalCodeService.getPostalCodes();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<PostalCode> getPostalCode(@PathVariable Long id) {
    return postalCodeService.getPostalCode(id);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePostalCode(@PathVariable Long id) {
    postalCodeService.deletePostalCode(id);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<PostalCode> savePostalCode(@RequestBody PostalCode postalCode) {
    return postalCodeService.savePostalCode(postalCode);
  }

  @GetMapping(value = "/zones", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCodeZone> getPostalCodeZones() {
    return postalCodeService.getPostalCodeZones();
  }

  @GetMapping(value = "/zone/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<PostalCodeZone> getPostalCodeZone(@PathVariable Long id) {
    return postalCodeService.getPostalCodeZone(id);
  }

  @PostMapping(value = "/zone", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<PostalCodeZone> savePostalCodeZone(@RequestBody PostalCodeZone postalCodeZone) {
    return postalCodeService.savePostalCodeZone(postalCodeZone);
  }

  @GetMapping(value = "/zone/{id}/availableCodes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PostalCode> getAvailablePostalCodesForZone(@PathVariable Long id) {
    return postalCodeService.getAvailablePostalCodesForZone(id);
  }

  @PostMapping(value = "/zone/{id}/postalCode", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<PostalCode> savePostalCodeToZone(@PathVariable Long id,
                                                                 @RequestBody PostalCode postalCode) {
    return postalCodeService.savePostalCodeToZone(id, postalCode);
  }

  @DeleteMapping(value = "/zone/{zoneId}/postalCode/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deletePostalCodeFromZone(@PathVariable Long zoneId,
                                       @PathVariable Long id) {
    postalCodeService.deletePostalCodeFromZone(zoneId, id);
  }
}
