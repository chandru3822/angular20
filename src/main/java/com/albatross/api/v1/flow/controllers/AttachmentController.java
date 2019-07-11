package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.services.AttachmentService;
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
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/attachment")
public class AttachmentController {

  @Autowired
  private AttachmentService attachmentService;

  // AttachmentType stuff (move to a different controller?)
  @RequestMapping(value = "/types", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getAttachmentTypes (@PathVariable Long companyId) {
    return attachmentService.getAttachmentTypesForCompany(companyId);
  }

  @RequestMapping(value = "/type/{typeId}",
      method = RequestMethod.DELETE,
      produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    attachmentService.deleteType(typeId);
  }

  @RequestMapping(value = "/type",
      method = RequestMethod.PUT,
      produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateProcess(@RequestBody AttachmentType type) {
    attachmentService.updateType(type);
  }

  @RequestMapping(value = "/type",
      method = RequestMethod.POST,
      produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<AttachmentType> insertProcess(@RequestBody AttachmentType type) {
    return attachmentService.insertType(type);
  }

}
