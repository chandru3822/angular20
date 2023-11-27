package com.albatross.api.pubsub.model;

import com.albatross.api.notification.model.NotificationTopic;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.experimental.Accessors;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@Accessors(chain = true)
public class RevokeAccessMessage implements IEventMessage {
  private Long userId;
  private String topic;

  @JsonIgnore
  @Override
  public Long getId() {
    return this.getUserId();
  }

  @Override
  public String getTopic() {
    return NotificationTopic.REVOKE_ACCESS.getName();
  }
}
