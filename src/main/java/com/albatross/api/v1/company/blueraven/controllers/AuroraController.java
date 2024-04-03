package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.aurora.AuroraDesignWrappedDTO;
import com.albatross.api.aurora.AuroraDesignListDTO;
import com.albatross.api.aurora.AuroraProxy;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/aurora", produces = MediaType.APPLICATION_JSON_VALUE)
public class AuroraController {

  private final AuroraProxy auroraProxy;

  @GetMapping(value = "/design/{designId}")
  public AuroraProxy.DesignSummary getDesign(@PathVariable String designId) throws IOException {
    return auroraProxy.getDesignSummary(designId);
  }

  @GetMapping(value = "/project/{projectId}/designs")
  public AuroraDesignListDTO getDesignsForProject(@PathVariable String projectId) throws IOException {
    return auroraProxy.getDesignsForProject(projectId);
  }

  @PostMapping(value = "/design/{designId}/duplicate")
  public AuroraDesignWrappedDTO duplicateAuroraDesign(@PathVariable String designId,
                                                      @RequestParam(required = false) String designName) throws IOException {
    return auroraProxy.duplicateDesign(designId, designName);
  }

}
