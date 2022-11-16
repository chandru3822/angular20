package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.smsQueue.TwilioMessageRequest;
import com.albatross.api.v1.flow.model.smsQueue.TwilioSMSResponse;
import com.albatross.api.v1.flow.services.MessagingService;
import com.albatross.api.v1.flow.services.SMSService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.twilio.twiml.MessagingResponse;
import com.twilio.twiml.TwiMLException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping(value = "/webhook/twilio")
@RequiredArgsConstructor
public class TwilioWebhookController {

  private final SMSService smsService;

  private final MessagingService messagingService;

  private final ObjectMapper objectMapper;

  @ResponseStatus(HttpStatus.OK)
  @PostMapping(
    value = "/sms",
    consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE,
    produces = MediaType.APPLICATION_XML_VALUE)
  public String updateSmsInfo(TwilioSMSResponse twilioSMS) throws TwiMLException {
    smsService.saveTwilioStatusUpdate(twilioSMS);
    return new MessagingResponse.Builder().build().toXml();
  }

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(
    value = "/inbound",
    consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE,
    produces = MediaType.APPLICATION_XML_VALUE)
  public String receiveInboundMessage(@RequestParam Map<String, Object> req) throws TwiMLException {
    final TwilioMessageRequest twilioSMS = objectMapper.convertValue(req, TwilioMessageRequest.class);
    smsService.saveReply(twilioSMS);
    messagingService.addNotifications(twilioSMS);
    return new MessagingResponse.Builder().build().toXml();
  }

  @ResponseStatus(HttpStatus.ACCEPTED)
  @PostMapping(value = "/process")
  public void processPayloads() {
    smsService.processTwilioWebhookPayloads();
  }
}
