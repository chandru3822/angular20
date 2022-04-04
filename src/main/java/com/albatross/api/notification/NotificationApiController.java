package com.albatross.api.notification;

import com.albatross.api.notification.model.Notification;
import com.albatross.api.notification.model.NotificationSubscriber;
import com.albatross.api.notification.model.NotificationTopic;
import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.Subscriber;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import io.micrometer.core.annotation.Timed;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import javax.validation.constraints.NotEmpty;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/notifications", produces = MediaType.APPLICATION_JSON_VALUE)
@Timed("notifications")
@RequiredArgsConstructor
public class NotificationApiController {

  private final NotificationService notificationService;
  private final PubSubService pubSubService;

  @GetMapping
  public Page<Notification> getUserNotifications(
      @AuthenticationPrincipal UserAccountDetails details, Pageable pageable) {
    return notificationService.getUserNotifications(details.getId(), pageable);
  }

  @PostMapping
  public ResponseEntity<Object> markNotificationAsRead(
      @RequestBody @Valid NotificationUpdatePayload payload,
      @AuthenticationPrincipal UserAccountDetails details)
      throws SQLException {
    notificationService.markUserNotificationsAsRead(details.getId(), payload.notificationIds());

    return ResponseEntity.ok().build();
  }

  @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
  public Subscriber getNotificationStreamSubscription(
      @AuthenticationPrincipal UserAccountDetails details,
      @RequestHeader(value = "Last-Event-ID", required = false) Long lastEventId,
      @RequestParam(value = "type", required = false, defaultValue = "")
          NotificationTopic... notificationTypes) {

    log.debug(
        "User={} started a server sent event stream with types={}",
        details.getUsername(),
        notificationTypes);

    final Subscriber subscriber =
        pubSubService.subscribe(
            new NotificationSubscriber(
                EventChannel.NOTIFICATION, details.getId(), Set.of(notificationTypes)));

    if (lastEventId != null) {
      notificationService.sendUserCatchupNotifications(subscriber, details.getId(), lastEventId);
    }

    return subscriber;
  }

  public record NotificationUpdatePayload(@NotEmpty List<Long> notificationIds) {}
}
