package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/flow/document")
public class DocumentController {
    @Value("${aws.storageBucket}")
    private String bucket;

    @Value("${aws.documents.keyPattern}")
    private String keyPattern;

    @Autowired
    private AttachmentService attachmentService;

//    @RequestMapping(value = "/urlPre/{id}", method = RequestMethod.GET)
//    public void getAttachmentUrlPre(@PathVariable Long id, HttpServletResponse response) throws IOException {
//        String attachmentUrl = attachmentService.getAttachmentPresignedUrlById(bucket, id);
//        response.sendRedirect(response.encodeRedirectURL(attachmentUrl));
//    }

    @RequestMapping(value = "/getSourceAttachments", method = RequestMethod.GET)
    public List<Attachment> getAttachmentsBySourceIdAndType(@RequestParam Long sourceId,
                                                            @RequestParam Long attachmentSourceTypeId) {
        return attachmentService.getAttachmentsBySourceIdAndType(bucket, sourceId, attachmentSourceTypeId);
    }

    @RequestMapping(method = RequestMethod.POST, value = "/upload")
    public Attachment uploadDocument(@RequestParam Long sourceId,
                                     @RequestParam Long attachmentSourceTypeId,
                                     @RequestParam("file") MultipartFile file) throws IOException {
        Attachment attachment = attachmentService.create(bucket, keyPattern, file);

        // Add to the join table
        attachmentService.addToJoinTable(attachment.getId(), sourceId, attachmentSourceTypeId, false);

        return attachment;
    }

    @RequestMapping(method = RequestMethod.DELETE, value = "/{id}")
    public void deleteDocument(@PathVariable("id") Long fileId) {
        attachmentService.delete(fileId);
    }
}