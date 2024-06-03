package com.albatross.api.push;

import com.google.firebase.messaging.FirebaseMessaging;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Service;

import java.util.Set;

@Slf4j
@Service
@ConditionalOnMissingBean(FirebaseMessaging.class)
public class FallbackPushNotificationService implements PushNotificationService {

  public FallbackPushNotificationService() {
    log.warn("Firebase push notifications through FCM are not enabled");
  }

  @Override
  public void pushNotification(@NonNull Message message, @NonNull Long userId) {
    pushNotification(message, Set.of(userId));
  }

  @Override
  public void pushNotification(@NonNull Message message, Set<Long> userIds) {
    log.info("Sending message: {} to users: {}", message, userIds);
  }

  @Override
  public void sendUnprocessedPushNotifications() {
    log.info("Processing Push Notification Queue");
  }

  @Override
  public void pruneTokens() {

  }
}
