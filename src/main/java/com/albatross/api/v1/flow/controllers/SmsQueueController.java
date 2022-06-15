package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.smsQueue.SMSQueueExportItem;
import com.albatross.api.v1.flow.model.smsQueue.SMSQueueItem;
import com.albatross.api.v1.flow.model.smsQueue.SmsQueueRow;
import com.albatross.api.v1.flow.services.SMSService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/flow/sms", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class SmsQueueController {

  private final SMSService smsService;

  @GetMapping(value = "/queue")
  public Page<SmsQueueRow> getQueue(Pageable pageable) {
    return smsService.getSmsQueue(pageable);
  }

  @GetMapping(value = "/exportQueue")
  public List<SMSQueueExportItem> exportQueue() {
    return smsService.exportSmsQueue();
  }

  @GetMapping(value = "/owners")
  public List<Owner> getOwners() {
    return smsService.getOwners();
  }

  @GetMapping(value = "/messages/{projectId}")
  public List<SMSQueueItem> getMessages(@PathVariable Long projectId) {
    return smsService.getSmsByProjectId(projectId);
  }

  @PostMapping(value = "/updateSms")
  public void updateSms(@RequestBody SMSQueueItem smsQueueItem) {
    smsService.updateSms(smsQueueItem);
  }
}
