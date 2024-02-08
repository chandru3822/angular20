package com.albatross.api.v1.company.blueraven.controllers.expenses;

import com.albatross.api.v1.company.blueraven.models.expenses.GlCode;
import com.albatross.api.v1.company.blueraven.services.expenses.GlCodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/glCodes")
public class GlCodeController {

  private final GlCodeService glCodeService;

  // gl code stuff
  @GetMapping(value = "/all")
  public List<GlCode> getAllGlCodes() {
    return glCodeService.getAllGlCodes();
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<GlCode> saveGlCode(@RequestBody GlCode glCode) {
    return glCodeService.saveGlCode(glCode);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteGlCode(@PathVariable Long id) {
    glCodeService.deleteGlCode(id);
  }

}
