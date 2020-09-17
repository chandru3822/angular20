package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.SMSQueueExportItem;
import com.albatross.api.v1.flow.model.SMSQueueItem;
import com.albatross.api.v1.flow.model.SMSQueuePage;
import com.albatross.api.v1.flow.services.SMSService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping(value = "/api/v1/flow/sms")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SmsQueueController {

    private final SMSService smsService;

    @GetMapping(value = "/queue")
    public Optional<SMSQueuePage> getQueue(@RequestParam(value = "groupId", required = false) String groupId,
                                           Pageable pageable) {
        return smsService.getSmsQueue(groupId, pageable);
    }

    @GetMapping(value = "/exportQueue")
    public List<SMSQueueExportItem> exportQueue() {
        return smsService.exportSmsQueue();
    }

    @GetMapping(value = "/messages/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<SMSQueueItem> getMessages(@PathVariable Long projectId) {
        return smsService.getSmsByProjectId(projectId);
    }
}
