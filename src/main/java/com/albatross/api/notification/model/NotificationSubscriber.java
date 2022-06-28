package com.albatross.api.notification.model;

import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.IEventMessage;
import com.albatross.api.pubsub.model.Subscriber;

import java.util.Objects;
import java.util.Set;

/**
 * Like a normal subscriber but we can be subscribed to specific notification type(s) that will be filtered out server-side
 */
public class NotificationSubscriber extends Subscriber {
  private final Set<NotificationTopic> subscribedTypes;

  public NotificationSubscriber(EventChannel eventChannel, Long userId, Set<NotificationTopic> subscribedTypes) {
    super(eventChannel, userId, Long.MAX_VALUE);
    this.subscribedTypes = subscribedTypes;
  }

  @Override
  public boolean acceptsEventMessage(IEventMessage eventMessage) {

    if (eventMessage instanceof NotificationEventMessage notificationEventMessage){

      boolean isTypeMatch =
        (subscribedTypes == null || subscribedTypes.isEmpty())
          || subscribedTypes.contains(notificationEventMessage.getNotificationTopic());

      final boolean isUserMatch =
        eventMessage.getUserId() == null || Objects.equals(this.userId, notificationEventMessage.getUserId());

      return isTypeMatch && isUserMatch;
    }

    return false;
  }
}
