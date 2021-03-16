package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.ContactLead;
import com.albatross.api.v1.company.blueraven.services.ContactLeadService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/contact")
public class ContactLeadController {
  private final ContactLeadService contactLeadService;

  @PostMapping(value = "/leadLabz", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadLabz(@RequestBody ContactLead contactLead) {
      contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadLabzCody", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadLabzCody(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadLabzNikita", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadLabzNikita(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadLabzShannon", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadLabzShannon(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadLabzWill", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadLabzWill(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadLabzZach", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadLabzZach(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/cleanEnergyAuthority", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactCleanEnergyAuthority(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/blueFireLeads", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactBlueFireLeads(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/solarReviews", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactSolarReviews(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/energyBillCruncher", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactEnergyBillCruncher(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/cleanEnergyExperts", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactCleanEnergyExperts(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/recursiveAdvertising", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactRecursiveAdvertising(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/rgr", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactRGR(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/bestCompany", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactBestCompany(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/fiveStrata", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactFiveStrata(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/hubspot", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactHubspot(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/facebook", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactFacebook(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/instagram", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactInstagram(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/youtube", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactYouTube(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/aurora", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactAurora(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/googlePpc", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactGooglePPC(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/googleDisplay", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactGoogleDisplay(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/faraday", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactFaraday(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/modernize", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactModernize(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }
}
