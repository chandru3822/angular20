package com.albatross.api.push;

import com.albatross.api.config.AppProperties;
import com.albatross.api.utils.SqlCache;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.Notification;
import jakarta.validation.constraints.Size;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.IntStream;

@Slf4j
@Service
@ConditionalOnBean(FirebaseMessaging.class)
@RequiredArgsConstructor
public class FirebasePushNotificationService implements PushNotificationService {
  private final AppProperties appProperties;
  private final FirebaseMessaging firebaseMessaging;
  private final SqlCache sqlCache;

  private final static String USER_NOTIFICATION_TOKENS_QUERY = """
      select token
      from flow.user_notification_token unt
      where unt.archived is false
        and unt.user_id in (:ids)
      order by user_id, date_modified desc
    """;

  @Async
  public void pushNotification(@NonNull Message message, @NonNull Long userId) {
    pushNotification(message, List.of(userId));
  }

  @Async
  public void pushNotification(@NonNull Message message, @Size(min = 1) List<Long> userIds) {
    log.info("Sending push notification to {} users", userIds.size());

    List<String> tokens = sqlCache.queryBySql(
      USER_NOTIFICATION_TOKENS_QUERY, Map.of("ids", userIds), new SingleColumnRowMapper<>(String.class));

    if (tokens == null || tokens.isEmpty()) {
      log.warn("No tokens available for selected users");
      return;
    }

    Notification notification = Notification.builder()
      .setTitle(message.title())
      .setBody(message.body())
      .build();

    //this is the maximum number of tokens firebase will allow at once
    int MAX_TOKENS = 500;
    IntStream.range(0, (tokens.size() + MAX_TOKENS - 1) / MAX_TOKENS)
      .mapToObj(i -> tokens.subList(i * MAX_TOKENS, Math.min(tokens.size(), (i + 1) * MAX_TOKENS)))
      .forEach(chunk -> {
        try {
          firebaseMessaging.sendEachForMulticast(MulticastMessage.builder()
            .addAllTokens(tokens)
            .setNotification(notification)
            .build(), appProperties.getFirebase().isDryRun());
        } catch (FirebaseMessagingException e) {
          throw new RuntimeException(e);
        }
      });
  }
}
