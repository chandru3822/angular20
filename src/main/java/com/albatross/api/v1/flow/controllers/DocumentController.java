package com.albatross.api.v1.flow.controllers;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = "/api/v1/flow/document")
public class DocumentController {

//    todo: @joe - the new attachment stuff should not require specific controllers for each type. you can just upload/get from the attachment controller

//    @Value("${aws.storageBucket}")
//    private String bucket;
//
//    @Value("${aws.documents.keyPattern}")
//    private String keyPattern;
//
//    @Autowired
//    private AttachmentService attachmentService;
//
////    @GetMapping(value = "/urlPre/{id}")
////    public void getAttachmentUrlPre(@PathVariable Long id, HttpServletResponse response) throws IOException {
////        String attachmentUrl = attachmentService.getAttachmentPresignedUrlById(bucket, id);
////        response.sendRedirect(response.encodeRedirectURL(attachmentUrl));
////    }
//
//    @GetMapping(value = "/getSourceAttachments")
//    public List<Attachment> getAttachmentsBySourceIdAndType(@RequestParam Long sourceId,
//                                                            @RequestParam Long attachmentSourceTypeId) {
//        return attachmentService.getAttachmentsBySourceIdAndType(sourceId, attachmentSourceTypeId);
//    }
//
//    @PostMapping(value = "/upload")
//    public Attachment uploadDocument(@RequestParam Long sourceId,
//                                     @RequestParam Long attachmentSourceTypeId,
//                                     @RequestParam("file") MultipartFile file) throws IOException {
//        Attachment attachment = attachmentService.create(file, sourceId, attachmentSourceTypeId, false);
//
//        return attachment;
//    }
//
//    @DeleteMapping(value = "/{id}")
//    public void deleteDocument(@PathVariable("id") Long fileId) {
//        attachmentService.delete(fileId);
//    }
}
