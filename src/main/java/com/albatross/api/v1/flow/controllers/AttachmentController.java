package com.albatross.api.v1.flow.controllers;

import java.io.IOException;
import java.util.List;

import javax.servlet.http.HttpServletResponse;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@RestController
@RequestMapping(value = "/api/v1/flow/attachment")
public class AttachmentController {

  @Autowired
  private AttachmentService attachmentService;

  @GetMapping(value = "")
  public List<Attachment> getAttachments(@RequestParam Long sourceId,
                                         @RequestParam Long attachmentTypeId) {
    return attachmentService.getAttachmentsBySourceIdAndType(sourceId, attachmentTypeId);
  }

  @GetMapping(value = "/{id}/url")
  public void getAttachmentUrl(@PathVariable Long id, HttpServletResponse response) throws IOException {
    String attachmentUrl = attachmentService.getAttachmentUrl(id);
    response.sendRedirect(attachmentUrl);
  }

  @ResponseStatus(HttpStatus.OK)
  @DeleteMapping(value = "/{id}")
  public void deleteAttachment(@PathVariable Long id) {
    attachmentService.delete(id);
  }

  @PostMapping(value = "")
  public Attachment uploadAttachment(@RequestParam Long sourceId,
                                     @RequestParam Long attachmentTypeId,
                                     @RequestParam("file") MultipartFile file) throws IOException {
    return attachmentService.create(file, sourceId, attachmentTypeId, true);
  }

  @GetMapping(value = "/getOne")
  public Attachment getOneBySourceIdAndType(@RequestParam Long sourceId,
                                            @RequestParam Long attachmentTypeId) {
    return attachmentService.getOneBySourceIdAndType(sourceId, attachmentTypeId);
  }
}
