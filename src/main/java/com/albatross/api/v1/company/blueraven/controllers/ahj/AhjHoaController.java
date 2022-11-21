package com.albatross.api.v1.company.blueraven.controllers.ahj;

import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.company.blueraven.services.ahj.AhjHoaService;
import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequestMapping(value = "/api/v1/company/blueraven/ahjHoa")
public class AhjHoaController {
  @Autowired
  private AhjHoaService ahjHoaService;

  @GetMapping(value = "/list/all")
  public List<AhjHoa> getAllAhjHoa() {
    return ahjHoaService.getAllAhjHoa();
  }

  @GetMapping(value = "/{id}")
  public Optional<AhjHoaDetail> getHoaById(@PathVariable Long id) {
    return ahjHoaService.getHoaById(id);
  }

  @PostMapping(value = "")
  public Optional<AhjHoaDetail> createHoa(@RequestBody AhjHoa hoa) {
    return ahjHoaService.updateHoa(hoa);
  }

  @PutMapping(value = "/simpleUpdate")
  public Optional<AhjHoaDetail> simpleUpdate(@RequestBody AhjHoa hoa) {
    return ahjHoaService.simpleUpdate(hoa);
  }

  @PutMapping(value = "")
  public Optional<AhjHoaDetail> editHoa(@RequestBody AhjHoa hoa) {
    return ahjHoaService.updateHoa(hoa);
  }

  @GetMapping(value = "/list/companies")
  public List<AhjHoaCompany> getAhjHoaCompanies() {
    return ahjHoaService.getAhjHoaCompanies();
  }

  // CONTACTS
  @PostMapping(value = "/{hoaId}/contacts")
  public Optional<AhjContact> addUtilityContact(@PathVariable Long hoaId,
                                                @RequestBody AhjContact utilityContact) {
    return ahjHoaService.saveHoaContact(hoaId, null, utilityContact);
  }

  @PutMapping(value = "/{hoaId}/contacts/{contactId}")
  public Optional<AhjContact> updateUtilityContact(@PathVariable Long hoaId,
                                                   @PathVariable Long contactId,
                                                   @RequestBody AhjContact utilityContact) {
    return ahjHoaService.saveHoaContact(hoaId, contactId, utilityContact);
  }

  @PutMapping(value = "/contacts/{contactId}/archive")
  public void deleteUtilityContact(@PathVariable Long contactId) {
    ahjHoaService.deleteHoaContact(contactId);
  }

  // LINKS
  @PostMapping(value = "/{hoaId}/links")
  public Optional<AhjLink> addUtilityLink(@PathVariable Long hoaId,
                                          @RequestBody AhjLink link) {
    return ahjHoaService.saveHoaLink(hoaId, null, link);
  }

  @PutMapping(value = "/{hoaId}/links/{linkId}")
  public Optional<AhjLink> updateUtilityLink(@PathVariable Long hoaId,
                                             @PathVariable Long linkId,
                                             @RequestBody AhjLink link) {
    return ahjHoaService.saveHoaLink(hoaId, linkId, link);
  }

  @PutMapping(value = "/links/{linkId}/archive")
  public void deleteUtilityLink(@PathVariable Long linkId) {
    ahjHoaService.deleteHoaLink(linkId);
  }
}
