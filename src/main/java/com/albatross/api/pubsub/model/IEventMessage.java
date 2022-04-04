package com.albatross.api.pubsub.model;

public interface IEventMessage {
  Long getId();

  Long getUserId();

  String getTopic();
}
