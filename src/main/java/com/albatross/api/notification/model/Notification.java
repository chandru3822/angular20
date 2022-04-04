package com.albatross.api.notification.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.experimental.Accessors;

import java.time.OffsetDateTime;
import java.util.Map;

@Data
@Accessors(chain = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Notification {
  private Long id;

  private Integer priority;

  private String title;

  private String body;

  private Long userId;

  private Map<String, Object> metadata;

  @JsonIgnore private Integer notificationTopicId;

  @JsonIgnore private OffsetDateTime messageReadTsz;

  public NotificationTopic getTopic() {
    if (this.notificationTopicId == null) {
      return NotificationTopic.UNKNOWN;
    }
    return NotificationTopic.values()[this.notificationTopicId];
  }

  public Notification setTopic(NotificationTopic notificationTopic) {
    this.notificationTopicId = notificationTopic.ordinal();
    return this;
  }
}
