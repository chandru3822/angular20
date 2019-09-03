package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@RestController
@RequestMapping(value = "/api/v1/flow/attachment")
public class AttachmentController {

  @Autowired
  private AttachmentService attachmentService;

  @RequestMapping(value = "", method = RequestMethod.GET)
  public List<Attachment> getAttachments(@RequestParam Long sourceId,
                                         @RequestParam Long attachmentSourceTypeId, @PathVariable String companyId) {
    return attachmentService.getAttachmentsBySourceIdAndType(sourceId, attachmentSourceTypeId);
  }

  @RequestMapping(value = "/{id}/url", method = RequestMethod.GET)
  public void getAttachmentUrl(@PathVariable Long id, HttpServletResponse response, @PathVariable String companyId) throws IOException {
    String attachmentUrl = attachmentService.getAttachmentUrl(id);
    response.sendRedirect(attachmentUrl);
  }

  @ResponseStatus(HttpStatus.OK)
  @RequestMapping(value = "/{id}", method = RequestMethod.DELETE)
  public void deleteAttachment(@PathVariable Long id) {
    attachmentService.delete(id);
  }

  @RequestMapping(value = "", method = RequestMethod.POST)
  public Attachment uploadAttachment(@RequestParam Long sourceId,
                                     @RequestParam Long attachmentSourceTypeId,
                                     @RequestParam("file") MultipartFile file) throws IOException {

    Attachment attachment = attachmentService.create(file, sourceId, attachmentSourceTypeId, true);

    return attachment;
  }

  @RequestMapping(value = "/getSourceAttachments", method = RequestMethod.GET)
  public List<Attachment> getAttachmentsBySourceIdAndType(@RequestParam Long sourceId,
                                                          @RequestParam Long attachmentSourceTypeId) {
    return attachmentService.getAttachmentsBySourceIdAndType(sourceId, attachmentSourceTypeId);
  }
}
