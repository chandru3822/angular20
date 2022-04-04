package com.albatross.api.pubsub;

import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.IEventMessage;
import com.albatross.api.pubsub.model.Subscriber;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
@RequiredArgsConstructor
public class PubSubService {

  private final RedisTemplate<String, Object> redisTemplate;
  private final Set<Subscriber> subscribers = ConcurrentHashMap.newKeySet();

  public Subscriber subscribe(Subscriber subscriber) {

    subscriber.onCompletion(() -> subscribers.remove(subscriber));
    subscriber.onTimeout(() -> subscribers.remove(subscriber));
    subscriber.onError((err) -> subscribers.remove(subscriber));

    subscribers.add(subscriber);
    log.debug("[PubSub] Subscriber count={}", subscribers.size());

    return subscriber;
  }

  @Async
  public void publish(EventChannel channel, IEventMessage notification) {
    redisTemplate.convertAndSend(channel.getName(), notification);
  }

  @Async
  public void broadcast(EventChannel channel, IEventMessage eventMessage) {
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
}
