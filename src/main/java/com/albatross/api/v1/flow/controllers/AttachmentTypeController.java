package com.albatross.api.v1.flow.controllers;

import java.util.List;
import java.util.Optional;

import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.ProcessStepAttachmentType;
import com.albatross.api.v1.flow.services.AttachmentTypeService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/attachmentType")
public class AttachmentTypeController {

  @Autowired
  private AttachmentTypeService attachmentTypeService;

  @RequestMapping(value = "/types", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getAttachmentTypes () {
    return attachmentTypeService.getAttachmentTypesForCompany();
  }

  @RequestMapping(value = "/typesForStep/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AttachmentType> getAvailableTypesForStep (@PathVariable Long id) {
    return attachmentTypeService.getAvailableTypesForProcessStep(id);
  }

  @RequestMapping(value = "/processStepType/{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProcessStepType(@PathVariable Long id) {
    attachmentTypeService.deleteProcessStepType(id);
  }

  @RequestMapping(value = "/processStepType", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProcessStepAttachmentType> insertProcessStepType(@RequestBody ProcessStepAttachmentType attachmentType) {
    return attachmentTypeService.insertProcessStepType(attachmentType);
  }

  @RequestMapping(value = "/type/{typeId}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    attachmentTypeService.deleteType(typeId);
  }

  @RequestMapping(value = "/type", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateType(@RequestBody AttachmentType type) {
    attachmentTypeService.updateType(type);
  }

  @RequestMapping(value = "/type", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<AttachmentType> insertType(@RequestBody AttachmentType type) {
    return attachmentTypeService.insertType(type);
  }

}
