package com.albatross.api.pubsub.model;

import java.util.Objects;

public interface ISubscriber {

  EventChannel getEventChannel();

  Long getUserId();

  default boolean acceptsEventMessage(IEventMessage eventMessage) {
    return eventMessage.getUserId() == null
        || Objects.equals(getUserId(), eventMessage.getUserId());
  }
}
