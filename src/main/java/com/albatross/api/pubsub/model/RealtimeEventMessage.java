package com.albatross.api.pubsub.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.experimental.Accessors;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@Accessors(chain = true)
public class RealtimeEventMessage implements IEventMessage {
  private Long userId;
  private String topic;
  private String title;
  private String body;
  private Object metadata;

  @JsonIgnore
  @Override
  public Long getId() {
    // note: real-time events most likely won't need an id
    return null;
  }
}
