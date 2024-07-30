package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smsQueue.SMSQueueItem;
import com.albatross.api.v1.flow.model.smsQueue.SmsQueueRow;
import com.albatross.api.v1.flow.services.SMSService;
import com.twilio.twiml.TwiMLException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/flow/sms", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class SmsController {

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

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(
    value = "/mock/inbound/project/{projectId}",
    consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE,
    produces = MediaType.APPLICATION_XML_VALUE)
  public String processMockInboundMessageProject(@PathVariable Long projectId) throws TwiMLException {
    return smsService.processMockInboundMessage(projectId, null);
  }

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(
    value = "/mock/inbound/user/{userId}",
    consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE,
    produces = MediaType.APPLICATION_XML_VALUE)
  public String processMockInboundMessageUser(@PathVariable Long userId) throws TwiMLException {
    return smsService.processMockInboundMessage(null, userId);
  }
}
