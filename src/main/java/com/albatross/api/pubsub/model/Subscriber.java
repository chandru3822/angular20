package com.albatross.api.pubsub.model;

import lombok.NonNull;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

public class Subscriber extends SseEmitter implements ISubscriber {
  protected final EventChannel eventChannel;
  protected final Long userId;

  public Subscriber(@NonNull EventChannel eventChannel, Long userId) {
    super(Long.MAX_VALUE);
    this.eventChannel = eventChannel;
    this.userId = userId;
  }

  @Override
  public Long getUserId() {
    return userId;
  }

  @Override
  public EventChannel getEventChannel() {
    return eventChannel;
  }
}
