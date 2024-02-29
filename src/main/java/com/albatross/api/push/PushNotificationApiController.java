package com.albatross.api.push;

import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@Hidden
@RestController
@RequestMapping(value = "/api/v1/flow/push", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class PushNotificationApiController {
  private final PushNotificationService pushNotificationService;

  public record PushNotificationPayload (String title, String message, List<Long> userIds){}

  @PostMapping
  public void pushNotifications(@RequestBody PushNotificationPayload payload){
    pushNotificationService.pushNotification(new Message(payload.title, payload.message), payload.userIds);
  }
}
