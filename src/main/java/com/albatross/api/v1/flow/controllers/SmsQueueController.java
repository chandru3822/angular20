package com.albatross.api.v1.flow.controllers;

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
  public Page<SmsQueueRow> getQueue(@RequestParam Long objectTypeId,
                                    @RequestParam(required = false) Boolean messageRead,
                                    Pageable pageable) {
    return smsService.getSmsQueue(pageable, objectTypeId, messageRead);
  }

  @GetMapping(value = "/messages/project/{projectId}")
  public List<SMSQueueItem> getProjectMessages(@PathVariable Long projectId) {
    return smsService.getSmsByProjectId(projectId);
  }

  @GetMapping(value = "/messages/user/{userId}")
  public List<SMSQueueItem> getUserMessages(@PathVariable Long userId) {
    return smsService.getSmsByUserId(userId);
  }

  @PostMapping(value = "/updateSms")
  public void updateSms(@RequestBody SMSQueueItem smsQueueItem) {
    smsService.updateSms(smsQueueItem);
  }
}
