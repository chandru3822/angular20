package com.albatross.api.notification.model;

import lombok.Data;
import lombok.experimental.Accessors;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import java.util.Map;

@Data
@Accessors(chain = true)
public class CreateNotificationDto {
  @NotBlank private NotificationTopic topic;

  private String title;

  @NotBlank private String body;

  @Min(0)
  @Max(100)
  private Integer priority;

  private Map<String, Object> metadata;

  public int getNotificationTopicId() {
    return topic.ordinal();
  }
}
