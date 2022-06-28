package com.albatross.api.pubsub.model;

import lombok.NonNull;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Objects;
import java.util.UUID;

public class Subscriber extends SseEmitter implements ISubscriber {
  protected final UUID uuid;
  protected final EventChannel eventChannel;
  protected final Long userId;

  public Subscriber(@NonNull EventChannel eventChannel, @NonNull Long userId) {
    this.uuid = UUID.randomUUID();
    this.eventChannel = eventChannel;
    this.userId = userId;
  }

  public Subscriber(@NonNull EventChannel eventChannel, @NonNull Long userId, long timeout) {
    super(timeout);
    this.uuid = UUID.randomUUID();
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

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    Subscriber that = (Subscriber) o;
    return uuid.equals(that.uuid)
        && eventChannel == that.eventChannel
        && userId.equals(that.userId);
  }

  @Override
  public int hashCode() {
    return Objects.hash(uuid, eventChannel, userId);
  }
}
