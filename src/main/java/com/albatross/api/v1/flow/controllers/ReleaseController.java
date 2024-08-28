package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyFeature;
import com.albatross.api.v1.flow.model.Feature;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.Release;
import com.albatross.api.v1.flow.services.ReleaseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by Alex Acevedo 06/27/23
 * Manage upcoming releases within Albatross
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/release", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class ReleaseController {

  private final ReleaseService releaseService;

  @GetMapping(value = "")
  public List<Release> getAllReleases() {
    return releaseService.getAllReleases();
  }

  @GetMapping(value = "/next")
  public Release getNextRelease() {
    return releaseService.getNextRelease();
  }

  @DeleteMapping(value = "/{id}")
  public List<Release> deleteFeature(@PathVariable Long id) {
    return releaseService.deleteRelease(id);
  }

  @PostMapping(value = "")
  public List<Release> saveFeature(@RequestBody Release release) {
    return releaseService.saveRelease(release);
  }

}
