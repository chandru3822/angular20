package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;

import com.albatross.api.utils.SqlCache;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@RestController
@RequestMapping(value = "/api/v1/flow/{companyId}/attachment")
public class AttachmentController {
  @Value("${aws.storageBucket}")
  private String bucket;

  @Value("${aws.photos.keyPattern}")
  private String keyPattern;

  @Autowired
  private AttachmentService attachmentService;

  @Autowired
  private SqlCache sqlCache;

  @RequestMapping(value = "", method = RequestMethod.GET)
  public List<Attachment> getAttachments(@RequestParam Long sourceId,
                                         @RequestParam Long attachmentSourceTypeId, @PathVariable String companyId) {
    return attachmentService.getAttachmentsBySourceIdAndType(bucket, sourceId, attachmentSourceTypeId);
  }

  @RequestMapping(value = "/{id}/url", method = RequestMethod.GET)
  public void getAttachmentUrl(@PathVariable Long id, HttpServletResponse response, @PathVariable String companyId) throws IOException {
    String attachmentUrl = attachmentService.getAttachmentUrl(bucket, id);
    response.sendRedirect(attachmentUrl);
  }

  @ResponseStatus(HttpStatus.OK)
  @RequestMapping(value = "/{id}", method = RequestMethod.DELETE)
  public void deleteAttachment(@PathVariable Long id, @PathVariable String companyId) {
    attachmentService.delete(id);
  }

  @RequestMapping(value = "", method = RequestMethod.POST)
  public Attachment uploadAttachment(@RequestParam Long sourceId,
                                     @RequestParam Long attachmentSourceTypeId,
                                     @RequestParam("file") MultipartFile file, @PathVariable String companyId) throws IOException {
    if(attachmentSourceTypeId == 9) {
      // Delete any existing user image before creating a new one
      attachmentService.deleteBySourceAndType(sourceId, attachmentSourceTypeId);
    }

    Attachment attachment = attachmentService.create(bucket, keyPattern, file);

    // Add to the join table
    HashMap<String, Object> params = new HashMap<>();
    params.put("attachmentId", attachment.getId());
    params.put("sourceId", sourceId);
    params.put("attachmentSourceTypeId", attachmentSourceTypeId);

    sqlCache.update("attachment.addToJoinTable", params);

    return attachment;
  }

  @RequestMapping(value = "/getSourceAttachments", method = RequestMethod.GET)
  public List<Attachment> getAttachmentsBySourceIdAndType(@RequestParam Long sourceId,
                                                          @RequestParam Long attachmentSourceTypeId) {
    return attachmentService.getAttachmentsBySourceIdAndType(bucket, sourceId, attachmentSourceTypeId);
  }
}
