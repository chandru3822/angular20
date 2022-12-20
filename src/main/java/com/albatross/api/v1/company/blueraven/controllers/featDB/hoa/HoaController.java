package com.albatross.api.v1.company.blueraven.controllers.featDB.hoa;

import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.company.blueraven.services.featDB.HoaService;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@Hidden
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/featDb/hoa")
public class HoaController {

  private final HoaService hoaService;

  @GetMapping(value = "/list/all")
  public List<Hoa> getAllHoa() {
    return hoaService.getAllHoa();
  }

  @GetMapping(value = "/{id}")
  public Optional<HoaDetail> getHoaById(@PathVariable Long id) {
    return hoaService.getHoaById(id);
  }

  @PostMapping(value = "")
  public Optional<HoaDetail> createHoa(@RequestBody Hoa hoa) {
    return hoaService.updateHoa(hoa);
  }

  @PutMapping(value = "/simpleUpdate")
  public Optional<HoaDetail> simpleUpdate(@RequestBody Hoa hoa) {
    return hoaService.simpleUpdate(hoa);
  }

  @PutMapping(value = "")
  public Optional<HoaDetail> editHoa(@RequestBody Hoa hoa) {
    return hoaService.updateHoa(hoa);
  }

  @GetMapping(value = "/list/companies")
  public List<HoaCompany> getHoaCompanies() {
    return hoaService.getHoaCompanies();
  }

  // CONTACTS
  @PostMapping(value = "/{hoaId}/contacts")
  public Optional<FeatDbContact> addUtilityContact(@PathVariable Long hoaId,
                                                   @RequestBody FeatDbContact utilityContact) {
    return hoaService.saveHoaContact(hoaId, null, utilityContact);
  }

  @PutMapping(value = "/{hoaId}/contacts/{contactId}")
  public Optional<FeatDbContact> updateUtilityContact(@PathVariable Long hoaId,
                                                      @PathVariable Long contactId,
                                                      @RequestBody FeatDbContact utilityContact) {
    return hoaService.saveHoaContact(hoaId, contactId, utilityContact);
  }

  @PutMapping(value = "/contacts/{contactId}/archive")
  public void deleteUtilityContact(@PathVariable Long contactId) {
    hoaService.deleteHoaContact(contactId);
  }

  // LINKS
  @PostMapping(value = "/{hoaId}/links")
  public Optional<FeatDbLink> addUtilityLink(@PathVariable Long hoaId,
                                             @RequestBody FeatDbLink link) {
    return hoaService.saveHoaLink(hoaId, null, link);
  }

  @PutMapping(value = "/{hoaId}/links/{linkId}")
  public Optional<FeatDbLink> updateUtilityLink(@PathVariable Long hoaId,
                                                @PathVariable Long linkId,
                                                @RequestBody FeatDbLink link) {
    return hoaService.saveHoaLink(hoaId, linkId, link);
  }

  @PutMapping(value = "/links/{linkId}/archive")
  public void deleteUtilityLink(@PathVariable Long linkId) {
    hoaService.deleteHoaLink(linkId);
  }
}
