package com.albatross.api.push;

import com.albatross.api.config.AppProperties;
import com.albatross.api.utils.SqlCache;
import com.google.firebase.messaging.*;
import jakarta.validation.constraints.Size;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Set;
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
      select distinct token
      from flow.user_notification_token unt
      where unt.archived is false
        and unt.user_id in (:ids)
        and unt.date_modified > now() - interval '60 days'
    """;

  private final static String USER_NOTIFICATION_TOKEN_PRUNE_QUERY = """
    update flow.user_notification_token
    set archived = true
    where archived is false
      and date_modified < now() - interval '60 days'
    """;

  @Async
  public void pushNotification(@NonNull Message message, @NonNull Long userId) {
    pushNotification(message, Set.of(userId));
  }

  @Async
  public void pushNotification(@NonNull Message message, @Size(min = 1) Set<Long> userIds) {
    log.info("[PushNotifications] Sending push notification to {} users", userIds.size());

    List<String> tokens = sqlCache.queryBySql(
      USER_NOTIFICATION_TOKENS_QUERY, Map.of("ids", userIds), new SingleColumnRowMapper<>(String.class));

    if (tokens == null || tokens.isEmpty()) {
      log.warn("[PushNotifications] No tokens available for selected users");
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
          BatchResponse batchResponse = firebaseMessaging.sendEachForMulticast(MulticastMessage.builder()
            .addAllTokens(chunk)
            .setNotification(notification)
            .build(), appProperties.getFirebase().isDryRun());

          //TODO: mark archived anything that returns an error
          batchResponse.getResponses().forEach(re -> {
            if (!re.isSuccessful()) {
              log.warn("[PushNotifications] Error sending notification: msg={}", re.getException().getMessage());
            }
          });
        } catch (FirebaseMessagingException e) {
          throw new RuntimeException(e);
        }
      });
  }

  @Scheduled(cron = "0 0 23 * * *", zone = "America/Denver")
  public void pruneTokens() {
    try {
      log.debug("[PushNotifications] Pruning tokens older than 60 days");
      sqlCache.executeSql(USER_NOTIFICATION_TOKEN_PRUNE_QUERY, Map.of());
    } catch (Exception e) {
      log.error("[PushNotifications] Error while pruning tokens, msg={}", e.getMessage());
    }
  }
}
