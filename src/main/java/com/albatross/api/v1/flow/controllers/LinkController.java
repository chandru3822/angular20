package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Link;
import com.albatross.api.v1.flow.model.processStep.ProcessStepLink;
import com.albatross.api.v1.flow.services.LinkService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/links")
public class LinkController {

  @Autowired
  private LinkService linkService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Link> getLinks () {
    return linkService.getLinksForCompany();
  }

  @PutMapping(value = "/updateOrderInProcessStep", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateOrderInProcessStep(@RequestBody List<ProcessStepLink> links) {
    linkService.updateOrderInProcessStep(links);
  }

  @GetMapping(value = "/processStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepLink> getLinksForProcessStep (@PathVariable Long id) {
    return linkService.getLinksForProcessStep(id);
  }

  @GetMapping(value = "/processStep/{id}/available", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Link> getAvailableLinksForStep (@PathVariable Long id) {
    return linkService.getAvailableLinksForProcessStep(id);
  }

  @GetMapping(value = "/action/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Link> getAvailableLinksForAction (@PathVariable Long id) {
    return linkService.getAvailableLinksForAction(id);
  }

  @DeleteMapping(value = "/processStep/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProcessStepLink(@PathVariable Long id) {
    linkService.deleteProcessStepLink(id);
  }

  @PostMapping(value = "/processStep", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepLink> insertProcessStepLink(@RequestBody ProcessStepLink link) {
    return linkService.insertProcessStepLink(link);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteLink(@PathVariable Long id) {
    linkService.deleteLink(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateLink(@RequestBody Link link) {
    linkService.updateLink(link);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Link> insertLink(@RequestBody Link link) {
    return linkService.insertLink(link);
  }

}
