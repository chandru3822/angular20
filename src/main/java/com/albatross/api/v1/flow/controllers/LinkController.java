package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Link;
import com.albatross.api.v1.flow.model.ProcessStepLink;
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
@RequestMapping(value = "/api/v1/flow/{companyId}/links")
public class LinkController {

  @Autowired
  private LinkService linkService;

  // AttachmentType stuff (move to a different controller?)
  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Link> getLinks (@PathVariable Long companyId) {
    return linkService.getLinksForCompany(companyId);
  }

  @RequestMapping(value = "/processStep/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Link> getAvailableLinksForStep (@PathVariable Long companyId,
                                                        @PathVariable Long id) {
    return linkService.getAvailableLinksForProcessStep(companyId, id);
  }

  @RequestMapping(value = "/action/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Link> getAvailableLinksForAction (@PathVariable Long companyId,
                                                @PathVariable Long id) {
    return linkService.getAvailableLinksForAction(companyId, id);
  }

  @RequestMapping(value = "/processStep/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProcessStepLink(@PathVariable Long id) {
    linkService.deleteProcessStepLink(id);
  }

  @RequestMapping(value = "/processStep", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepLink> insertProcessStepLink(@RequestBody ProcessStepLink link) {
    return linkService.insertProcessStepLink(link);
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteLink(@PathVariable Long id) {
    linkService.deleteLink(id);
  }

  @RequestMapping(value = "", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateLink(@RequestBody Link link) {
    linkService.updateLink(link);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Link> insertLink(@RequestBody Link link) {
    return linkService.insertLink(link);
  }

}
