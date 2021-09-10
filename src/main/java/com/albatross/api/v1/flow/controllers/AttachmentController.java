package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/attachment")
public class AttachmentController {

  private final AttachmentService attachmentService;

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
  public Attachment uploadAttachment(@RequestParam(required = false) Long sourceId,
                                     @RequestParam Long attachmentTypeId,
                                     @RequestParam(required = false, defaultValue = "true") Boolean deleteFirst,
                                     @RequestParam("file") MultipartFile file) throws IOException {
    return attachmentService.create(file, sourceId, attachmentTypeId, deleteFirst);
  }

  @PutMapping(value = "/{id}")
  public Attachment updateAttachment(@PathVariable Long id,
                                     @RequestBody Attachment attachment) {
    return attachmentService.update(id, attachment);
  }

  @GetMapping(value = "/getOne")
  public Attachment getOneBySourceIdAndType(@RequestParam Long sourceId,
                                            @RequestParam Long attachmentTypeId) {
    return attachmentService.getOneBySourceIdAndType(sourceId, attachmentTypeId);
  }

  @GetMapping(value = "/getAttachmentPresignedUrlsForUserList")
  public Map<Long, String> getAttachmentPresignedUrlsForUserList(@RequestParam List<Long> sourceIds,
                                                                 @RequestParam Long attachmentTypeId) {
    return attachmentService.getAttachmentPresignedUrlsForUserList(sourceIds, attachmentTypeId);
  }
}
