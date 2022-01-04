package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.ContactLead;
import com.albatross.api.v1.company.blueraven.services.ContactLeadService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
  public ResponseEntity<Object> updateContactCleanEnergyAuthority(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
    return ResponseEntity.ok("");
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

  @PostMapping(value = "/solarLeadFactory", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactSolarLeadFactory(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/insideSales", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactInsideSales(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/envyusMedia", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactEnvyusMedia(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/snapchat", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactSnapchat(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadseed", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadSeed(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadvision", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadVision(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/optindatacorp", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactOptInDataCorp(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/solardirectappt", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactSolarDirectAppt(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/strategicsolarsolutions", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactStrategicSolarSolutions(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/encompassleads", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactEncompassLeads(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/lightload", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLightload(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/mvfglobal", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactMvfglobal(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/wishone", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactWishone (@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/amplifysolarmarketing", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactAmplifySolarMarketing(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadgenesis", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadGenesis(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/allieddigitalmedia", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactAlliedDigitalMedia(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/solarmarketingexperts", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactSolarMarketingExperts(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/consumervoice", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactConsumerVoice(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/leadcactus", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactLeadCactus(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/threeships", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactThreeShips(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/ascendmedia", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactAscendMedia(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

  @PostMapping(value = "/solarwizard", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateContactSolarWizard(@RequestBody ContactLead contactLead) {
    contactLeadService.saveContactLead(contactLead);
  }

}
