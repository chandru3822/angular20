package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.AttachmentType;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AppService;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/app")
public class AppController {


    private final AppService appService;
    private final AttachmentService attachmentService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Attachment> getApps() {
        return attachmentService.getAttachmentsByType(AttachmentType.APP_DOWNLOAD.id);
    }

    @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public void deleteApp(@PathVariable Long id) {
        attachmentService.delete(id);
    }

    @PutMapping(value = "/show", produces = MediaType.APPLICATION_JSON_VALUE)
    public void getApps(@RequestBody Attachment attachment) {
        attachmentService.showOrHideAttachment(attachment);
    }
}
