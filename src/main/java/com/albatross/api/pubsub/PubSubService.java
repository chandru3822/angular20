package com.albatross.api.pubsub;

import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.IEventMessage;
import com.albatross.api.pubsub.model.Subscriber;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@EnableScheduling
@RequiredArgsConstructor
public class PubSubService {

  private static final String LAST_MESSAGE_RECV = "lastMessageRecv";
  private final RedisTemplate<String, Object> redisTemplate;
  private final Set<Subscriber> subscribers = ConcurrentHashMap.newKeySet();

  @PreAuthorize("hasFeatureAccess('SMS_INBOX')") // NOTE: currently tied to this feature
  public Subscriber subscribe(Subscriber subscriber) {

    subscriber.onCompletion(() -> subscribers.remove(subscriber));
    subscriber.onTimeout(() -> subscribers.remove(subscriber));
    subscriber.onError((err) -> subscribers.remove(subscriber));

    subscribers.add(subscriber);
    log.debug(
        "[PubSub] Subscriber count={}, userId={}", subscribers.size(), subscriber.getUserId());

    // send an initial event so the front end knows to keep reconnecting
    try {
      sendKeepAlive(subscriber);
    } catch (IOException e) {
      log.error("[PubSub] Error sending initial keepalive ping", e);
      subscriber.completeWithError(e);
    }

    return subscriber;
  }

  @Async
  public void publish(EventChannel channel, IEventMessage notification) {
    redisTemplate.convertAndSend(channel.getName(), notification);
  }

  @Async
  public void broadcast(EventChannel channel, @NonNull IEventMessage eventMessage) {

    setLastMessageRecv();

    subscribers.stream()
        .filter(subscriber -> subscriber.getEventChannel() == channel)
        .filter(subscriber -> subscriber.acceptsEventMessage(eventMessage))
        .forEach(subscriber -> notify(subscriber, eventMessage));
  }

  public void notify(Subscriber subscriber, IEventMessage eventMessage) {
    try {
      SseEmitter.SseEventBuilder event = SseEmitter.event();

      final Long eventMessageId = eventMessage.getId();
      if (eventMessageId != null) {
        event.id(eventMessageId.toString());
      }

      event.name(eventMessage.getTopic()).data(eventMessage).reconnectTime(5000);
      subscriber.send(event);
    } catch (Exception exception) {
      log.debug("[PubSub] Unable to process message to subscriber. Removing from list");
      subscriber.completeWithError(exception);
    }
  }

  private void setLastMessageRecv() {
    // value is not important
    redisTemplate
        .opsForValue()
        .set(
            LAST_MESSAGE_RECV,
            OffsetDateTime.now().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME),
            Duration.ofSeconds(90));
  }

  private Object getLastMessageRecv() {
    return redisTemplate.opsForValue().get(LAST_MESSAGE_RECV);
  }

  /**
   * there really isn't a greate way to know if a client closes a connection so we broadcast a
   * simple ping message periodically allowing us to close the connection on the server side
   */
  @Scheduled(fixedDelay = 90, initialDelay = 90, timeUnit = TimeUnit.SECONDS)
  protected void broadcastKeepAlive() {
    try {

      // only send it out if we haven't had a message sent out in the last 90 seconds
      if (getLastMessageRecv() == null) {
        Set<Subscriber> deadEmitters = new HashSet<>();

        log.debug("[PubSub] Sending out ping");
        subscribers.forEach(
            sub -> {
              try {
                this.sendKeepAlive(sub);
              } catch (IOException e) {
                log.debug(
                    "[PubSub] Error sending keepalive ping (likely client closed connection)", e);
                deadEmitters.add(sub);
              }
            });

        if (!deadEmitters.isEmpty()) {
          log.info("[PubSub] Removing {} dead emitters", deadEmitters.size());
          deadEmitters.forEach(this.subscribers::remove);
        }
      }
    } catch (Exception e) {
      log.error("[PubSub] Error during broadcast keepalive ping", e);
    }
  }

  private void sendKeepAlive(Subscriber subscriber) throws IOException {
    final String message =
        "ping event sent at %s"
            .formatted(DateTimeFormatter.ISO_DATE_TIME.format(OffsetDateTime.now()));
    subscriber.send(SseEmitter.event().name("ping").data(message).reconnectTime(5000));
  }
}
