package com.albatross.api.pubsub;

import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.Subscriber;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/api/v1/flow/stream")
@RequiredArgsConstructor
public class PubSubApiController {

  private final PubSubService pubSubService;

  @GetMapping(value = "/events", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
  public Subscriber handleSSE(@AuthenticationPrincipal UserAccountDetails details) {
    log.debug("{} started a server sent event stream", details.getUsername());
    return pubSubService.subscribe(new Subscriber(EventChannel.REAL_TIME_EVENT, details.getId()));
  }
}
