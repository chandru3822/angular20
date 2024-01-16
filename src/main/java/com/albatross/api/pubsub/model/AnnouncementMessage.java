package com.albatross.api.pubsub.model;

import com.albatross.api.notification.model.NotificationTopic;
import com.albatross.api.v1.flow.model.Announcement;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.experimental.Accessors;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@Accessors(chain = true)
public class AnnouncementMessage implements IEventMessage {
  private String topic;
  private Announcement announcement;

  @JsonIgnore
  @Override
  public Long getId() {
    // note: dont need any ids for this update
    return null;
  }

  @JsonIgnore
  @Override
  public Long getUserId() {
    // note: real-time events most likely won't need a user id
    return null;
  }

  @Override
  public String getTopic() {
    return NotificationTopic.ANNOUNCEMENT.getName();
  }
}
