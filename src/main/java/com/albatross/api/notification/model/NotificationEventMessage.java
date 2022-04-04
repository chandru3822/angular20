package com.albatross.api.notification.model;

import com.albatross.api.pubsub.model.IEventMessage;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.experimental.Accessors;

import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@Accessors(chain = true)
public class NotificationEventMessage implements IEventMessage {

  private Long id;
  private Long userId;
  @JsonIgnore private NotificationTopic notificationTopic;
  private String title;
  private String body;
  private Integer priority;
  private Map<String, Object> metadata;

  @Override
  public String getTopic() {
    return this.notificationTopic.getName();
  }

  @JsonProperty
  public void setTopic(NotificationTopic notificationTopic) {
    this.notificationTopic = notificationTopic;
  }

  public static NotificationEventMessage from(Notification notification) {
    return new NotificationEventMessage()
        .setId(notification.getId())
        .setUserId(notification.getUserId())
        .setNotificationTopic(notification.getTopic())
        .setTitle(notification.getTitle())
        .setBody(notification.getBody())
        .setPriority(notification.getPriority())
        .setMetadata(notification.getMetadata());
  }
}
